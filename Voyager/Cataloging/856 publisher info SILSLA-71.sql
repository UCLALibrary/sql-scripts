/*  Bib 856 fields with publisher info
    Random 10000-row sample.
    SILSLA-71
*/

with bibs as (
  select distinct
    record_id
  , field_seq
  , replace(substr(indicators, 2, 1), ' ', '_') as ind2
  from vger_subfields.ucladb_bib_subfield
  where tag like '856%'
  and ( subfield like '%Publisher''s description%'
    or  subfield like '%Publisher description%'
    or  subfield like '%Publication information%'
  )
  -- Random sample, 10000 rows
  order by dbms_random.value
  fetch first 10000 rows only
)
select
  b.record_id as bib_id
, b.ind2
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = b.record_id
) as locs
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = b.record_id and field_seq = b.field_seq and tag = '8563' and rownum < 2) as f8563
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = b.record_id and field_seq = b.field_seq and tag = '856z' and rownum < 2) as f856z
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = b.record_id and field_seq = b.field_seq and tag = '856a' and rownum < 2) as f856a
, vger_subfields.getfieldfromsubfields(b.record_id, b.field_seq) as f856
from bibs b
order by bib_id
;
