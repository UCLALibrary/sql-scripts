with bibs as (
  select 
    bib_id
  --, field_008
  from bib_text
  where (
        substr(field_008, 24, 1) = 'o' -- 008/23
    or  substr(field_008, 30, 1) = 'o' -- 008/29
  )
)
select *
from bibs b
where not exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = b.bib_id
  and tag = '856z'
  and upper(subfield) like '%RESTRICTED%'
)
and not exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = b.bib_id
  and tag = '856x'
  and subfield = 'CDL'
)
and not exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = b.bib_id
  and tag = '910a'
  and subfield like '%marcive%'
)
order by bib_id
;
--13274 bibs
