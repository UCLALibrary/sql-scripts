/*  Law print records with 856 fields
    SILSLA-56
*/

with bibs as (
  select 
    bs.record_id as bib_id
  , bs.indicators
  , vger_subfields.getfieldfromsubfields(record_id, field_seq) as f856
  from vger_subfields.ucladb_bib_subfield bs
  where tag = '856x'
  and subfield like 'UCLA Law%'
  and indicators != '42'
)
, law as (
  select b.*
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code like 'lw%'
) 
--, d as (
select distinct
  bib_id
, indicators
, f856
from law
--) select count(*), count(distinct bib_id) from d; --2901 rows, 2751 bibs
order by bib_id
;
