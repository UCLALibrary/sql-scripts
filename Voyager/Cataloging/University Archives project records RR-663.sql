/*  University Archive records for OCLC updating project.
    RR-663
*/

with bibs as (
  select distinct record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '910a'
  and subfield like 'kal/ejf%' --399
  --398
  minus
  select distinct record_id as bib_id
  from vger_subfields.ucladb_bib_subfield bs
  where (tag = '948b' and subfield = 'klb')
  and exists (
    select * from vger_subfields.ucladb_bib_subfield
    where record_id = bs.record_id
    and field_seq = bs.field_seq
    and tag = '948k'
    and subfield like '%upoclc2%'
  )
  --325 fields
)
, f948_fields as (
  select distinct
    record_id as bib_id, field_seq
  from vger_subfields.ucladb_bib_subfield
  where record_id in (select bib_id from bibs)
  and tag like '948%'
)
-- 161 fields, 152 records
select
  f.bib_id
, vger_support.get_oclc_number(f.bib_id) as oclc
, (select vger_support.unifix(title) from bib_text where bib_id = f.bib_id) as title
, vger_subfields.getfieldfromsubfields(f.bib_id, f.field_seq) as f948
, ( select listagg(l.location_code, ', ') within group(order by l.location_code)
    from bib_location bl inner join location l on bl.location_id = l.location_id
    where bl.bib_id = f.bib_id
) as locs
from f948_fields f
order by f.bib_id, f.field_seq
;
