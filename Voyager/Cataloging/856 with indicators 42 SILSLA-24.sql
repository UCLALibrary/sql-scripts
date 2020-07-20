/*  Bibs with 856 fields with indicators 42.
    SILSLA-24
*/

with bibs as (
  select distinct
    record_id, field_seq, indicators
  from vger_subfields.ucladb_bib_subfield
  where tag like '856%'
  and indicators = '42'
  and rownum < 10001 -- SAMPLE FOR NOW
)
--select count(distinct record_id), count(*) from bib
select
  b.record_id as bib_id
, ( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from bib_location bl
    inner join ucladb.location l2 on bl.location_id = l2.location_id
    where bl.bib_id = b.record_id
) as locs
, vger_subfields.getfieldfromsubfields(b.record_id, b.field_seq) as f856
from bibs b
order by b.record_id, b.field_seq
;
-- 61466 bibs	78118 urls
