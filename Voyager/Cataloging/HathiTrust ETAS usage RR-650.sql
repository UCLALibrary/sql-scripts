truncate table vger_report.tmp_rr_650;
drop table vger_report.tmp_rr_650 purge;
CREATE TABLE vger_report.tmp_rr_650 ( checkout_date DATE,
  htid VARCHAR2(255),
  access_lvl NUMBER(3),
  rights VARCHAR2(255),
  ht_bib_key NUMBER(11),
  description VARCHAR2(255),
  source VARCHAR2(255),
  source_bib_num VARCHAR2(255),
  oclc_num VARCHAR2(255),
  isbn VARCHAR2(1024),
  issn VARCHAR2(255),
  lccn VARCHAR2(255),
  title VARCHAR2(1024),
  imprint VARCHAR2(350),
  rights_reason_code VARCHAR2(255),
  rights_timestamp DATE,
  us_gov_doc_flag NUMBER(3),
  rights_date_used NUMBER(6),
  pub_place VARCHAR2(255),
  lang VARCHAR2(255),
  bib_fmt VARCHAR2(255),
  collection_code VARCHAR2(255),
  content_provider_code VARCHAR2(255),
  responsible_entity_code VARCHAR2(255),
  digitization_agent_code VARCHAR2(255),
  access_profile_code VARCHAR2(255),
  author VARCHAR2(256),
  uniques NUMBER(4),
  renewals NUMBER(4)
)
;
-- Data imported from latest cumulative file, etas_item_report_ucla_2021-02-10.txt
select count(*) from vger_report.tmp_rr_650;
-- 34599 rows
create index vger_report.ix_tmp_rr_650 on vger_report.tmp_rr_650 (ht_bib_key);

select count(*)
from vger_report.tmp_rr_650 r
inner join vger_report.hathi_overlap h on r.ht_bib_key = h.hathi_bib_key
;
--32278 rows

select count(*)
from vger_report.tmp_rr_650 r
where exists (
  select * from vger_report.hathi_overlap where hathi_bib_key = r.ht_bib_key
)
;
-- 6246 rows do not match; 28353 do

select ht_bib_key, count(*) as num
from vger_report.tmp_rr_650 r
group by ht_bib_key
having count(*) > 1
order by num desc
;
-- Some titles with multiple items have been used 200+ times

select vger_support.unifix(title), title from vger_report.tmp_rr_650;


-- OCLC# for non-matching (non-UCLA?) records
select distinct
  regexp_substr(r.oclc_num, '[^,]+', 1, 1) as oclc_num
from vger_report.tmp_rr_650 r
where not exists (
  select * from vger_report.hathi_overlap where hathi_bib_key = r.ht_bib_key
)
order by to_number(oclc_num)
;

select count(*), count(distinct ht_bib_key) from tmp_rr_650 where oclc_num is null; --345 rows, 190 distinct bibs

select distinct ht_bib_key from tmp_rr_650 where oclc_num is null;



-- Best query, using what we have
with matches as (
  select distinct
    r.ht_bib_key
  , regexp_substr(r.oclc_num, '[^,]+', 1, 1) as oclc_r
  --, h.oclc_number as oclc_o
  , h.bib_id
  , r.author
  , r.title
  , r.imprint
  , r.pub_place
  , r.lang
  , r.bib_fmt
  , r.rights_date_used
  from vger_report.tmp_rr_650 r
  left outer join vger_report.hathi_overlap h on r.ht_bib_key = h.hathi_bib_key
)
select
/*
  m.oclc_r as oclc_number
, m.bib_id
, 'https://www.worldcat.org/oclc/' || m.oclc_r as permalink
, ( select subfield
    from vger_subfields.ucladb_bib_subfield
    where record_id = m.bib_id
    and tag in ('050a', '060a')
    and rownum < 2
    -- can't add an order by here, causes "missing right parentheses" error....
) as classification
, coalesce(bt.bib_format, m.bib_fmt) as bib_fmt
, coalesce(bt.place_code, m.pub_place) as place_code
, coalesce(bt.language, m.lang) as language
, bt.date_type_status as dttp
, coalesce(bt.begin_pub_date, to_char(m.rights_date_used)) as begin_pub_date
, bt.end_pub_date
, vger_support.unifix(coalesce(bt.author, m.author)) as author
, vger_support.unifix(coalesce(bt.title, m.title)) as title
, vger_support.unifix(coalesce(bt.imprint, m.imprint)) as imprint
, case
    when m.bib_id is not null
    then 'Y'
    else null
end as clu
*/
count(*)
from matches m
left outer join ucladb.bib_text bt on m.bib_id = bt.bib_id
where bt.bib_id is null
--order by to_number(oclc_number)
;
-- 34599	20069 in tmp
-- 32278	16129 tmp joined with overlap
-- 20187	20069 joined after distinct, without rights data
-- 190 null oclc_r; 3940 null oclc_h (and bib_id) due to LOJ; same 190 have both null
--select count(*), count(distinct ht_bib_key) from matches


