/*  Bib 700 fields with $e containing 'former owner' and no $5.
    VBT-1754
*/

select 
  bs.record_id as bib_id
, vger_subfields.getfieldfromsubfields(bs.record_id, bs.field_seq) as f700
from vger_subfields.ucladb_bib_subfield bs
where tag = '700e'
and upper(subfield) like '%FORMER%OWNER%'
and not exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = bs.record_id
  and field_seq = bs.field_seq
  and tag = '7005'
)
order by bib_id
;

