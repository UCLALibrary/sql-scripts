/*  LSC Biomed bibs with 541 fields.
    Two reports: 
    #1: Only LSC Biomed holdings
    #2: LSC Biomed holdings and any others
    
    RR-601
*/

with bibs as (
  select distinct
    record_id as bib_id
  , field_seq
  , indicators
  from vger_subfields.ucladb_bib_subfield
  where tag like '541%'
)
, bio as (
  select 
    bm.bib_id
  , bm.mfhd_id
  , b.field_seq
  , b.indicators
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code in (
    'bihi', 'bihibjnl', 'bihimi', 'bihipam', 'bihirest', 'birfhist', 'bisc', 'biscboxm', 'biscboxs', 'bisccg', 
    'bisccg*', 'bisccg**', 'bisccgma', 'biscrbr', 'biscrbr*', 'biscrbrb', 'biscsr', 'biscvlt', 'biscvlt*', 'biscvlt**', 'srbi2'
  )
)
--select count(distinct bib_id) from bio c;
select distinct
  c.bib_id
, c.field_seq
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and field_seq = c.field_seq and tag = '5413' and rownum < 2) as f541_3
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and field_seq = c.field_seq and tag = '5415' and rownum < 2) as f541_5
, vger_subfields.GetFieldFromSubfields(c.bib_id, c.field_seq) as f541
from bio c
-- #1: where not exists (
-- #2: where exists (
where not exists (
  select *
  from bib_mfhd
  where bib_id = c.bib_id
  and mfhd_id not in (select mfhd_id from bio)
)
order by bib_id, field_seq
;
-- 11692 bibs: 408 with other holdings, 11284 without

