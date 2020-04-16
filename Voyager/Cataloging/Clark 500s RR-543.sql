/*  Clark Library bibs with 500 fields.
    Two reports: 
    #1: Only Clark holdings
    #2: Clark holdings and any others
    
    RR-543
*/

with bibs as (
  select distinct
    record_id as bib_id
  , field_seq
  from vger_subfields.ucladb_bib_subfield
  where tag like '500%'
)
, clark as (
  select 
    bm.bib_id
  , bm.mfhd_id
  , b.field_seq
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code like 'ck%'
)
--select count(distinct bib_id) from clark;
select distinct
  c.bib_id
, vger_subfields.GetFieldFromSubfields(c.bib_id, c.field_seq) as f500
from clark c
-- #1: where not exists (
-- #2: where exists (
where r-543rrexists (
  select *
  from bib_mfhd
  where bib_id = c.bib_id
  and mfhd_id not in (select mfhd_id from clark)
)
order by bib_id
;
-- 71285 (57595, 13690)


