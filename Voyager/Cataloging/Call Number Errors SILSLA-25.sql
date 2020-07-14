/*  Call Number Errors in Voyager Holdings Records
    SILSLA-25
    
    Needs to run at a quiet time when no changes are happening, and subfield db is up to date!
*/

with base as (
  select *
  from vger_subfields.ucladb_mfhd_subfield x
  where x.tag = '852b'
  and (subfield != 'in' and subfield not like 'sr%' and subfield not like '%acq%')
  and (
      exists (
        select * from vger_subfields.ucladb_mfhd_subfield
        where record_id = x.record_id
        and tag = '852h'
        and indicators like ' %'
      )
    or not exists (
      select * from vger_subfields.ucladb_mfhd_subfield
      where record_id = x.record_id
      and tag = '852h'
    )
  )
  and not exists (
    select * from vger_subfields.ucladb_mfhd_subfield
    where record_id = x.record_id
    and (tag like '852%' or tag like '866%')
    and ( upper(subfield) like '%IN PROCESS%' or upper(subfield) like '%SEE INDIVIDUAL%' or subfield like '%CSP%')
  )
)
--select count(*) from base; -- 135320
select
  bm.bib_id
, bm.mfhd_id
, l.location_code
, replace(b.indicators, ' ', '_') as ind
, vger_subfields.getfieldfromsubfields(b.record_id, b.field_seq, 'mfhd') as f852
from base b
inner join bib_mfhd bm on b.record_id = bm.mfhd_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
and mm.suppress_in_opac = 'N'
order by location_code, bib_id, mfhd_id
;

