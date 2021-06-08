/*  Incorrectly coded 856 fields (post-GDC cleanup check)
    SILSLA-115
*/

with bibs as (
  select distinct
    record_id
  , field_seq
  , replace(indicators, ' ', '_') as indicators
  , subfield as f8563
  from vger_subfields.ucladb_bib_subfield
  where tag = '8563'
  and substr(indicators, 2, 1) not in ('0', '1')
  and ( 1=0
    or  upper(subfield) like '%AVAILABLE%'
    or  upper(subfield) like '%COVERAGE%'
    or  upper(subfield) like '%CURRENT%'
    or  upper(subfield) like '%EDITION%'
    or  upper(subfield) like '%ISSUE%'
    or  upper(subfield) like '%LATEST%'
    or  upper(subfield) like '%RESTRICTED TO%'
    or  upper(subfield) like '%SELECTED%'
  )
  -- Exclusions
  and upper(subfield) not like '%FINDING AID%'
union all
  select distinct
    record_id
  , field_seq
  , replace(indicators, ' ', '_') as indicators
  , subfield as f8563
  from vger_subfields.ucladb_bib_subfield
  where tag = '8563'
  and substr(indicators, 2, 1) not in ('0', '1')
  and (subfield like '1%' or subfield like '2%')
)
--select count(*) from bibs; --50
select
  b.record_id as bib_id
, b.indicators
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = b.record_id
) as locs
, b.f8563
, vger_subfields.getfieldfromsubfields(b.record_id, b.field_seq) as f856
from bibs b
order by bib_id
;
