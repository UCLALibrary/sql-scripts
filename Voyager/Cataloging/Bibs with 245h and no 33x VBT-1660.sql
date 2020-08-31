/*  Bib records with 245 $h and no 336/7/8
    VBT-1660
*/

with bibs as (
  select *
  from vger_subfields.ucladb_bib_subfield bs
  where bs.tag = '245h'
  and not exists (
    select *
    from vger_subfields.ucladb_bib_subfield
    where record_id = bs.record_id
    and regexp_like(tag, '^33[678]')
  )
  and record_id > 9000000
)
select 
  b.record_id as bib_id
, b.subfield as f245h
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = b.record_id
) as locs
, ( select subfield 
    from vger_subfields.ucladb_bib_subfield
    where record_id = b.record_id
    and tag = '948a'
    and field_seq = ( 
      select field_seq 
      from vger_subfields.ucladb_bib_subfield 
      where record_id = b.record_id 
      and tag = '948c'
      and subfield = (
        select max(subfield)
        from vger_subfields.ucladb_bib_subfield 
        where record_id = b.record_id 
        and tag = '948c'
    )
  )
) as latest_f948a
from bibs b
;

/*** New approach: record counts by 245 $h ***/
with bibs as (
  select 
    record_id as bib_id
  , regexp_replace(bs.subfield, '].*$', ']') as subfield
  from vger_subfields.ucladb_bib_subfield bs
  where bs.tag = '245h'
  and not exists (
    select *
    from vger_subfields.ucladb_bib_subfield
    where record_id = bs.record_id
    and regexp_like(tag, '^33[678]')
  )
)
select
  b.subfield
, l.location_code
, count(*) as records
from bibs b
inner join bib_location bl on b.bib_id = bl.bib_id
inner join location l on bl.location_id = l.location_id
group by b.subfield, l.location_code
order by subfield, location_code
;