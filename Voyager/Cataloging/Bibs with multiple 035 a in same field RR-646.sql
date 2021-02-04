/*  Bib records with multiple 035 $a in the same field.
    RR-646
*/
with bibs as (
  select
    bs.record_id as bib_id
  , vger_subfields.getfieldfromsubfields(record_id, field_seq, 'bib', 'ucladb') as f035
  from vger_subfields.ucladb_bib_subfield bs
  where tag = '035a'
  group by record_id, tag, field_seq
  having count(*) > 1
)
select
  b.bib_id
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = b.bib_id
) as locs
, b.f035
from bibs b
order by b.bib_id
;
