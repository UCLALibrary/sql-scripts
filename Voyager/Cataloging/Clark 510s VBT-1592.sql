/*  Clark Library bibs with 510 fields.
    Two reports: 
    #1: Only Clark holdings
    #2: Clark holdings and any others
    
    VBT-1592
*/

with bibs as (
  select distinct
    record_id as bib_id
  , field_seq
  , indicators
  from vger_subfields.ucladb_bib_subfield
  where tag like '510%'
)
, clark as (
  select 
    bm.bib_id
  , bm.mfhd_id
  , b.field_seq
  , b.indicators
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code like 'ck%'
)
--select count(distinct bib_id) from clark c;
select distinct
  c.bib_id
, replace(c.indicators, ' ', '_') as indicators
, vger_subfields.GetFieldFromSubfields(c.bib_id, c.field_seq) as f510
from clark c
-- #1: where not exists (
-- #2: where exists (
where not exists (
  select *
  from bib_mfhd
  where bib_id = c.bib_id
  and mfhd_id not in (select mfhd_id from clark)
)
order by bib_id
;
-- 22370 bibs (21363 no other holdings, 1007 other holdings)


