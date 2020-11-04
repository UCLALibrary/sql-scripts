/*  Law internet holdings - 2 reports.
    SILSLA-34
*/

-- Report 1: Law non-Internet records with Internet holdings for 856 42 fields
with bibs as (
  select 
    record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '856x'
  and subfield like 'UCLA Law%'
  and indicators = '42'
)
, law as (
  select distinct
    b.bib_id
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code like 'lw%'
)
, internet as (
  select distinct
    b.bib_id
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code = 'in'
)
select bib_id
from law l
where exists (select * from internet where bib_id = l.bib_id)
order by bib_id
;
-- 48 bibs

-- Report 2: Law Internet records with at least one 856 42 field
with bibs01 as (
  select 
    record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '856x'
  and subfield like 'UCLA Law%'
  and indicators in ('40', '41')
)
, bibs2 as (
  select 
    record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '856x'
  and subfield like 'UCLA Law%'
  and indicators = '42'
  and record_id in (select bib_id from bibs01)
)
select distinct
  b.bib_id
from bibs2 b
inner join bib_mfhd bm on b.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
where l.location_code = 'in'
and not exists (
  select *
  from bib_mfhd
  where bib_id = b.bib_id
  and mfhd_id != bm.mfhd_id
)
order by b.bib_id
;
-- 237 bibs
