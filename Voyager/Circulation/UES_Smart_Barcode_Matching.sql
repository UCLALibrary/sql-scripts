create table vger_report.tmp_ues_barcodes (
  location_code varchar2(10)
, call_no varchar2(50)
, author varchar2(50)
, title varchar2(50)
, barcode varchar2(20)
)
;
-- imported 23977 rows from "lab school items with sequence.xls"
-- fix known bad data
update vger_report.tmp_ues_barcodes set barcode = 'L 010 729 102 3' where barcode = 'L 010 729 102 3,';
commit;
create index vger_report.ix_tmp_ues_barcodes on vger_report.tmp_ues_barcodes (location_code, call_no, author, title);

-- David's original query
-- Currently (2014-08-04): 23904 rows, with spurious item info
-- Remove item joins, save remaining data for comparison with tmp_ues_barcodes
create table vger_report.tmp_ues_mfhds as
SELECT
	l.location_code,
	mm.display_call_no AS call_no,
	substr(bt.author, 1, 37) AS author,
	substr(bt.title_brief, 1, 37) AS title,
--	mi.item_enum,
--	mi.chron,
--	mi.caption,
--  bi.item_id,
  mm.mfhd_id,
  bm.bib_id
FROM
	ucladb.mfhd_master mm
	INNER JOIN ucladb.bib_mfhd bm ON mm.mfhd_id = bm.mfhd_id
	INNER JOIN ucladb.bib_text bt ON bm.bib_id = bt.bib_id
	INNER JOIN ucladb.location l ON mm.location_id = l.location_id
-- 	LEFT OUTER JOIN ucladb.bib_item bi ON bt.bib_id = bi.bib_id
--	LEFT OUTER JOIN ucladb.mfhd_item mi ON mm.mfhd_id = mi.mfhd_id
WHERE
	mm.location_id IN (438,440,441,442,443,444,445,446,447,449,450,451,452,454,455,456,457,458) -- most but not all 'ue' locations
;
-- 21922 rows, without items - all distinct mfhd_ids
create index vger_report.ix_tmp_ues_mfhds on vger_report.tmp_ues_mfhds (location_code, call_no, author, title, mfhd_id);

-- Final decision: load all barcodes (even dups), staff will clean up.
-- So, pull mfhd_id into barcode data.
-- Use jaro winkler similarity match (avail in Oracle, soundex is too limited) with arbitrary threshhold of 90 (out of 100).
-- Replace corrupt diacritics in David's data (??) with single ? for slightly better comparison with UTF8-in-ASCII7 diacritics in my mfhd data.
-- Coalesce comparable fields to get 'X' if null, for comparisons.
drop table vger_report.tmp_ues_barcode_matches purge;
create table vger_report.tmp_ues_barcode_matches as
select
  b.location_code
, b.call_no
, m.call_no as m_call_no
, utl_match.jaro_winkler_similarity(coalesce(replace(b.call_no, '??', '?'), 'X'), coalesce(m.call_no, 'X')) as call_no_jaro_sim
, b.barcode
, b.author
, m.author as m_author
, utl_match.jaro_winkler_similarity(coalesce(replace(b.author, '??', '?'), 'X'), coalesce(m.author, 'X')) as author_jaro_sim
, b.title
, m.title as m_title
, utl_match.jaro_winkler_similarity(coalesce(replace(b.title, '??', '?'), 'X'), coalesce(m.title, 'X')) as title_jaro_sim
, m.mfhd_id
, m.bib_id
from vger_report.tmp_ues_barcodes b, vger_report.tmp_ues_mfhds m
where b.location_code = m.location_code
and   utl_match.jaro_winkler_similarity(coalesce(replace(b.call_no, '??', '?'), 'X'), coalesce(m.call_no, 'X')) >= 90
and   utl_match.jaro_winkler_similarity(coalesce(replace(b.author, '??', '?'), 'X'), coalesce(m.author, 'X')) >= 90
and   utl_match.jaro_winkler_similarity(coalesce(replace(b.title, '??', '?'), 'X'), coalesce(m.title, 'X')) >= 90
;
-- For batchcat updates
grant select on vger_report.tmp_ues_barcode_matches to ucla_preaddb;
-- 27060 rows: 23812 distinct barcode, 21862 distinct mfhd_id
select count(*), count(distinct barcode), count(distinct mfhd_id) from vger_report.tmp_ues_barcode_matches;

-- Report rejects with identical max scores
with barcodes as (
  select 
    barcode
  , max(call_no_jaro_sim + author_jaro_sim + title_jaro_sim) as max_score
  from vger_report.tmp_ues_barcode_matches
  group by barcode
)
--23812 barcodes have matched, get the rows with the best match
, data as (
  select
    m.*
  from barcodes b
  inner join vger_report.tmp_ues_barcode_matches m on b.barcode = m.barcode
  where b.max_score = m.call_no_jaro_sim + m.author_jaro_sim + m.title_jaro_sim
)
-- Some barcodes have multiple rows with best matches... 276 rows in total, for 103 barcodes.
-- Can't distinguish among them so reject for manual cleanup.
select * from data
where barcode in (
  select barcode from data group by barcode having count(*) > 1
)
order by barcode, bib_id, mfhd_id
;

-- Final query with data for updating Voyager
with barcodes as (
  select 
    barcode
  , max(call_no_jaro_sim + author_jaro_sim + title_jaro_sim) as max_score
  from vger_report.tmp_ues_barcode_matches
  group by barcode
)
-- 23812 rows in barcodes
, data as (
  select
    m.*
  from barcodes b
  inner join vger_report.tmp_ues_barcode_matches m on b.barcode = m.barcode
  where b.max_score = m.call_no_jaro_sim + m.author_jaro_sim + m.title_jaro_sim
)
-- 23985 rows in data (23812 distinct barcodes, but 103 have multiple best scores due to limited data)
, rejects as (
  -- Some barcodes have multiple rows with best matches... 276 rows in total.
  -- Can't distinguish among them so reject for manual cleanup
  select * from data
  where barcode in (
    select barcode from data group by barcode having count(*) > 1
  )
)
, updates as (
  select * from data
  minus
  select * from rejects
)
-- 23709 distinct barcodes remain (23812 - 103)
-- Each barcode will go onto one mfhd, though some mfhds will get multiple barcodes (which staff will clean up manually).
-- Dump full set of updates to Excel as UES_Barcodes_Main_File.xlsx fir reporting; use just barcode and mhfd_id for updating Voyager
--select * from updates order by barcode, bib_id, mfhd_id
select mfhd_id, barcode
from updates
order by mfhd_id, barcode
;

-- After Voyager update (23709 barcodes added, above)
-- Original barcode data where barcode not added to Voyager: 268 rows, reported as UES_Barcodes_Main_File_Rejects.xlsx
select *
from vger_report.tmp_ues_barcodes m
where not exists (
  select * from ucladb.item_barcode where item_barcode = replace(m.barcode, ' ', '')
)
order by barcode;
;

-- UES holdings records with multiple barcodes: 696 sets totaling 2690 rows, reported as UES_Barcodes_Main_File_Duplicates.xlsx
--with d as (
select
  l.location_code
, mm.mfhd_id
, count(*) as barcodes
, mm.display_call_no
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title
from ucladb.mfhd_master mm
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join ucladb.item_barcode ib on mi.item_id = ib.item_id
inner join ucladb.item i on mi.item_id = i.item_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
where l.location_code like 'ue%'
and trunc(i.create_date) = to_date('2014-08-06', 'YYYY-MM-DD')
group by l.location_code, mm.display_call_no, mm.mfhd_id, vger_support.unifix(bt.author), vger_support.unifix(bt.title_brief)
having count(*) > 1
order by l.location_code, mm.mfhd_id
--) select sum(barcodes) from d
;

/**********************************************************
* Second file of data, but better (?!) data so no need for
* hoop-jumping as with first set.
**********************************************************/
drop table vger_report.tmp_ues_barcodes2 purge;
create table vger_report.tmp_ues_barcodes2 (
  location_code varchar2(10)
, barcode varchar2(20)
, call_no varchar2(50)
, author varchar2(50)
, title varchar2(50)
, mfhd_id int
, bib_id int
)
;
grant select on vger_report.tmp_ues_barcodes2 to ucla_preaddb;
-- imported 669 rows from "lab school items 071814 with sequence.xls",
-- created by manually combining with "other lab school locations_edited for vendor.csv" to get mfhd_id and location

-- Load all of these
select * from vger_report.tmp_ues_barcodes2 order by mfhd_id, barcode;

-- A few dups due to incorrect export, for manual cleanup
select * from vger_report.tmp_ues_barcodes2
where mfhd_id in (select mfhd_id from vger_report.tmp_ues_barcodes2 group by mfhd_id having count(*) > 1)
order by mfhd_id, barcode
;

-- Add barcodes using same Batchcat program, just pointing to tmp_ues_barcodes2
