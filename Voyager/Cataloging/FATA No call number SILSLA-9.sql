/*  FATA holdings with no call number (852 $h only).
    SILSLA-9
*/

select
  record_id as mfhd_id
, vger_subfields.getfieldfromsubfields(record_id, field_seq, 'mfhd', 'filmntvdb') as f852
from vger_subfields.filmntvdb_mfhd_subfield s
where tag = '852b'
and not exists (
  select *
  from vger_subfields.filmntvdb_mfhd_subfield
  where record_id = s.record_id
  and field_seq = s.field_seq
  and tag = '852h'
)
order by mfhd_id
;