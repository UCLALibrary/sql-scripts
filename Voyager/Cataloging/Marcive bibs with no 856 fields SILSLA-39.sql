/*  Marcive bibs with no 856 fields.
    SILSLA-39.
*/

with bibs as (
  select bs.record_id as bib_id
  from vger_subfields.ucladb_bib_subfield bs
  where tag = '910a'
  and subfield like '%marcive%'
  and not exists (
    select *
    from vger_subfields.ucladb_bib_subfield
    where record_id = bs.record_id
    and tag like '856%'
  )
)
select distinct
  b.bib_id
, substr(bt.bib_format, 2, 1) as bib_lvl
, l.location_code
from bibs b
inner join bib_text bt on b.bib_id = bt.bib_id
inner join bib_mfhd bm on b.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
order by b.bib_id, l.location_code
;