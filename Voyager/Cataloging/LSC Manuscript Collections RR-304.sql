/*  LSC Manuscript collections, selected locations
    RR-304, refinement of RR-282
    Revised again 2017-10-19, on VBT-304
    Revised again 2018-10-09, on RR-396
*/
-- Create working table for performance/analysis
create table vger_report.tmp_vbt304 as
select distinct
  l.location_code
, mm.display_call_no
, mm.suppress_in_opac as mfhd_suppr
, bm.mfhd_id
, bm.bib_id
-- join is fast but requires de-duping
, replace(bi.normal_heading, 'UCOCLC', '') as oclc
, bt.bib_format -- LDR/06-07 http://www.loc.gov/marc/bibliographic/bdleader.html
, vger_support.unifix(bt.title_brief) as title_brief
, bs.indicators
, bs.subfield as f856u
from ucladb.location l
inner join ucladb.mfhd_master mm on l.location_id = mm.location_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
-- join is fast but requires de-duping
left outer join ucladb.bib_index bi
  on bt.bib_id = bi.bib_id
  and bi.index_code = '0350'
  and bi.normal_heading like 'UCOCLC%'
left outer join vger_subfields.ucladb_bib_subfield bs
  on bt.bib_id = bs.record_id
  and bs.tag = '856u'
  and bs.indicators = '42'
where mm.call_no_type = '8'
and l.location_code in ('musc', 'srar2', 'sryr2', 'yrspstax')
and bt.bib_format in ('ac', 'am', 'bc', 'km', 'pc', 'pd', 'tc')
;

select count(distinct bib_id), count(*) from vger_report.tmp_vbt304;
-- 2017-09-26: 5964	5997
with d as (select distinct bib_id, mfhd_id, oclc from vger_report.tmp_vbt304)
select count(*) from d
;
-- 2017-09-26: 5988

-- Remove rows where bib has multiple OCLC numbers, keeping just the "lowest"
-- per string comparison.
delete from vger_report.tmp_vbt304 b
where (bib_id, oclc) in (
  with dups as (
    select bib_id, oclc
    from vger_report.tmp_vbt304 b
    where exists (
      select * from vger_report.tmp_vbt304
      where bib_id = b.bib_id
      and mfhd_id = b.mfhd_id
      and oclc != b.oclc
    )
  )
  select bib_id, oclc
  from dups d
  where oclc != (
    select min(oclc) from dups where bib_id = d.bib_id
  )
)
;
-- 0 rows
commit;

-- Data exported to Excel
select
  d.*
, vger_subfields.GetSubfields(d.bib_id, '040e') as f040e
, vger_subfields.GetSubfields(d.bib_id, '300a,300f') as f300_af
-- 20181009 another change: Add 540 per RR-396
, vger_support.unifix(ucladb.GetMarcField(d.bib_id, 0, 0, '540', '', 'abcdu3568')) as f540
, (select count(*) from ucladb.mfhd_item where mfhd_id = d.mfhd_id) as items
from vger_report.tmp_vbt304 d
order by location_code, bib_id, mfhd_id
;

-- Clean up
drop table vger_report.tmp_vbt304 purge;
