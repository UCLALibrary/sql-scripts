/*  Holdings records with 541 field(s).
    Nearly all are Clark, but list others for cleanup.
    VBT-1788
*/

with mfhds as (
  select distinct
    record_id as mfhd_id
  , vger_subfields.getfieldfromsubfields(record_id, field_seq, 'mfhd', 'ucladb') as f541
  from vger_subfields.ucladb_mfhd_subfield ms
  where tag like '541%'
)
select
  bm.bib_id
, bm.mfhd_id
, l.location_code
, mm.display_call_no
, m.f541
from mfhds m
inner join mfhd_master mm on m.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join bib_mfhd bm on m.mfhd_id = bm.mfhd_id
order by l.location_code, bm.mfhd_id
;