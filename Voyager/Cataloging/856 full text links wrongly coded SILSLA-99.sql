/*  Incorrectly-coded 856 full-text links that need fixing
    SILSLA-99
*/

with bibs as (
  select distinct
    record_id
  , field_seq
  , replace(indicators, ' ', '_') as indicators
  from vger_subfields.ucladb_bib_subfield
  where tag in ('856a', '856z', '8563')
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
    or  subfield like '1%'
    or  subfield like '2%'
  )
  -- 1841 subfields; 1794 distinct fields
)
--select count(*) from bibs;
select
  b.record_id as bib_id
, b.indicators
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
