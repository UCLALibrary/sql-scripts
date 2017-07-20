/*  LSC Manuscript collections, with separate reports for Biomed and not-Biomed.
    RR-282
*/
-- Create working table for performance/analysis
create table vger_report.tmp_vbt282 as
select distinct
  l.location_code
, mm.display_call_no
, mm.suppress_in_opac as mfhd_suppr
, bm.mfhd_id
, bm.bib_id
-- subquery didn't finish in 10+ hours
/*
, ( select replace(normal_heading, 'UCOCLC', '')
    from ucladb.bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
) as oclc
*/
-- join is fast but requires de-duping
, replace(bi.normal_heading, 'UCOCLC', '') as oclc
, bt.bib_format -- LDR/06-07 http://www.loc.gov/marc/bibliographic/bdleader.html
, vger_support.unifix(bt.title_brief) as title_brief
, ( select subfield
    from vger_subfields.ucladb_bib_subfield
    where record_id = bt.bib_id
    and tag = '524a'
    and rownum < 2
) as f524a
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
  and bs.indicators in ('41', '42')
where mm.call_no_type = '8'
and ( l.location_code in ('srar2', 'srbi2', 'sryr2', 'sryr7')
  or  l.location_code like 'arsc%'
  or  l.location_code like 'bihi%' -- maybe not needed...
  or  l.location_code in ('bisc', 'bisccgma', 'bisccg', 'biscvlt')
  or  l.location_code like 'musc%'
  or  l.location_code like 'uaref%'
  or  l.location_code like 'yrsp%'
)
;

select count(distinct bib_id), count(*) from vger_report.tmp_vbt282;
-- 2017-07-20: 88328	107475
with d as (select distinct bib_id, mfhd_id, oclc from vger_report.tmp_vbt282)
select count(*) from d
;
-- 2017-07-20: 107216

-- Remove rows where bib has multiple OCLC numbers, keeping just the "lowest"
-- per string comparison.
delete from vger_report.tmp_vbt282 b
where (bib_id, oclc) in (
  with dups as (
    select bib_id, oclc
    from vger_report.tmp_vbt282 b
    where exists (
      select * from vger_report.tmp_vbt282
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
-- 5 rows
commit;

-- Data exported to Excel
-- Two reports: one for Biomed, one for other locs
-- 1) Biomed
select
  d.*
, vger_subfields.GetSubfields(d.bib_id, '040e') as f040e
from vger_report.tmp_vbt282 d
where location_code in ('srbi2', 'bisc', 'bisccgma', 'bisccg', 'biscvlt')
and upper(display_call_no) like '%MS. COLL%'
order by location_code, bib_id, mfhd_id
;

-- 2) Other locs
select
  d.*
, vger_subfields.GetSubfields(d.bib_id, '040e') as f040e
from vger_report.tmp_vbt282 d
where location_code in ('musc', 'srar2', 'sryr2', 'sryr7', 'uaref', 'yrspstax')
and bib_format in ('am', 'as', 'bc', 'bd', 'bm', 'cc', 'dc', 'kc', 'pc', 'pd', 'tc')
order by location_code, bib_id, mfhd_id
;

-- Clean up
drop table vger_report.tmp_vbt282 purge;
