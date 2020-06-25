/*  Holdings records with 852 $c, for cleanup.
    SILSLA-6
*/
with mfhds as (
  select distinct
    record_id
  , field_seq
  , indicators
  from vger_subfields.ucladb_mfhd_subfield
  where tag = '852c'
)
select 
  mm.mfhd_id
, l.location_code
, replace(m.indicators, ' ', '_') as ind
, vger_subfields.getfieldfromsubfields(m.record_id, m.field_seq, 'mfhd') as f852
from mfhds m
inner join mfhd_master mm on m.record_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
order by location_code, mfhd_id
;

select subfield, count(*) as flds
from vger_subfields.ucladb_mfhd_subfield
where tag = '852c'
group by subfield
order by flds desc, subfield
;
