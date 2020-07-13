/*  Clark bibs with 856 fields.
    SILSLA-22
*/

with clark as (
  select distinct
    bm.bib_id
  from bib_mfhd bm
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code like 'ck%'
)
select distinct
  c.bib_id
, ( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from bib_location bl
    inner join ucladb.location l2 on bl.location_id = l2.location_id
    where bl.bib_id = c.bib_id
) as locs
, replace(bs.indicators, ' ', '_') as ind
, vger_subfields.getfieldfromsubfields(bs.record_id, bs.field_seq) as f856
from clark c
inner join vger_subfields.ucladb_bib_subfield bs
  on c.bib_id = bs.record_id
  and bs.tag like '856%'
order by c.bib_id
;