/*  Reports on 856 with "Continued online only".
    SILSLA-41.
*/

-- Report 1: Only Internet holdings
with bibs as (
  select
    record_id as bib_id
  , vger_subfields.getfieldfromsubfields(record_id, field_seq) as f856
  from vger_subfields.ucladb_bib_subfield
  where tag like '856%'
  and lower(subfield) like '%continued%online%only%'
)
, mfhds as (
  select
    bm.bib_id
  , bm.mfhd_id
  , l.location_code
  , b.f856
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
)
select distinct
  m.bib_id
, m.f856
from mfhds m
where m.location_code != 'in'
and not exists (
  select * from mfhds where bib_id = m.bib_id and location_code != 'in'
)
order by bib_id
;
-- 48 fields, 87 bib/mfhd pairs total, 30 distinct bibs


-- Report 2: Internet holdings and others
with bibs as (
  select
    record_id as bib_id
  , vger_subfields.getfieldfromsubfields(record_id, field_seq) as f856
  from vger_subfields.ucladb_bib_subfield
  where tag like '856%'
  and lower(subfield) like '%continued%online%only%'
)
, mfhds as (
  select
    bm.bib_id
  , bm.mfhd_id
  , l.location_code
  , b.f856
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
)
select distinct
  m.bib_id
, m.mfhd_id
, m.location_code
, m.f856
from mfhds m
where m.location_code != 'in'
and exists (
  select * from mfhds where bib_id = m.bib_id and location_code = 'in'
)
order by bib_id
;

