/*  Law SuDocs data, based on list of bib ids provided by them.
    Data imported from Excel file.
    RR-291
*/
select count(*), count(distinct bib_id) from vger_report.tmp_sudocs_rr291;
-- 55499 rows, 55091 distinct; 263 sets of multiple ids, from 2-13 occurrences, like bib 3353905

-- Dedup via table swap
create table vger_report.tmptmptmp as select distinct bib_id from vger_report.tmp_sudocs_rr291;
drop table vger_report.tmp_sudocs_rr291 purge;
create table vger_report.tmp_sudocs_rr291 as select * from vger_report.tmptmptmp;
drop table vger_report.tmptmptmp purge;

-- Index for performance
alter table vger_report.tmp_sudocs_rr291 add constraint pk_tmp_sudocs_rr291 primary key (bib_id);

-- Data for report
-- As of 2017-07-28, 5 bibs have no holdings (presumably bib and/or holdings already deleted).
with srlf as (
  select
    r.bib_id
  , mm.mfhd_id as srlf_mfhd_id
  , l.location_code as srlf_loc_code
  , l.location_name as srlf_loc_name
  , (select count(*) from ucladb.mfhd_item where mfhd_id = mm.mfhd_id) as srlf_items
  , (select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '866a' and rownum < 2) as srlf_f866a
  from vger_report.tmp_sudocs_rr291 r
  inner join ucladb.bib_mfhd bm on r.bib_id = bm.bib_id
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join ucladb.location l on mm.location_id = l.location_id
  where l.location_code like 'sr%' -- All SRLF locations, not just stacks
)
select
  r.bib_id
, mm.mfhd_id
, l.location_code
--, mm.normalized_call_no
, mm.display_call_no
, (select count(*) from ucladb.mfhd_item mi where mfhd_id = mm.mfhd_id) as law_items
, (select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '866a' and rownum < 2) as law_f866a
, vger_support.unifix(bt.title) as title
, case when s.bib_id is not null then 'Y' else null end as has_srlf
, s.srlf_loc_name
, s.srlf_mfhd_id
, s.srlf_items
, s.srlf_f866a
, vger_support.unifix(bt.author) as author
, bt.publisher_date as f260c
, ( select vger_subfields.GetFieldFromSubfields(record_id, field_seq) 
    from vger_subfields.ucladb_bib_subfield
    where record_id = r.bib_id
    and tag like '086%'
    and rownum < 2
) as f086 -- first 086 only
from vger_report.tmp_sudocs_rr291 r
inner join ucladb.bib_text bt on r.bib_id = bt.bib_id
inner join ucladb.bib_mfhd bm on r.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
left outer join srlf s on r.bib_id = s.bib_id
where l.location_code like 'lw%'
order by mm.normalized_call_no
;

-- Some bibs have multiple SRLF holdings: examples 9393 and 121448
with srlf as (
  select
    r.bib_id
  , mm.mfhd_id
  , l.location_code
  , (select count(*) from ucladb.mfhd_item where mfhd_id = mm.mfhd_id) as srlf_items
  , (select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '866a' and rownum < 2) as srlf_f866a
  from vger_report.tmp_sudocs_rr291 r
  inner join ucladb.bib_mfhd bm on r.bib_id = bm.bib_id
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join ucladb.location l on mm.location_id = l.location_id
  where l.location_code like 'sr%'
)
select * from srlf
where bib_id in (select bib_id from srlf group by bib_id having count(*) > 1)
order by bib_id;

-- Clean up
drop table vger_report.tmp_sudocs_rr291 purge;
