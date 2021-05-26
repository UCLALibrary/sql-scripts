/*  Bib 856 fields with Abstract (and similar) info
    Random 5000-row sample if more than 5K results.
    SILSLA-73
*/

with bibs as (
  select distinct
    record_id
  , field_seq
  , replace(indicators, ' ', '_') as indicators
  , replace(substr(indicators, 2, 1), ' ', '_') as ind2
  from vger_subfields.ucladb_bib_subfield
  where (tag like '856%' and tag not in ('856u', '856x'))
  and ( upper(subfield) like '%ABSTRACT%' --includes ABSTRACTS
    or  upper(subfield) like '%BOOK REVIEW%' --includes BOOK REVIEWS
    or  upper(subfield) like '%FOREWORD%'
    or  upper(subfield) like '%INTRODUCTION%'
    or  upper(subfield) like '%SAMPLE%' --includes SAMPLE TEXT and SAMPLE CHAPTER
    or  upper(subfield) like '%SUMMAR%' --includes SUMMARIES
    or  upper(subfield) like '%SYNOPS?S%' --includes SYNOPSES and SYNOPSIS
  )
  -- 3399 matches, before exclusions
  minus
  select distinct
    record_id
  , field_seq
  , replace(indicators, ' ', '_') as indicators
  , replace(substr(indicators, 2, 1), ' ', '_') as ind2
  from vger_subfields.ucladb_bib_subfield
  where (tag like '856%' and tag not in ('856u', '856x'))
  and ( upper(subfield) like '%ADDITION%' --includes ADDITIONAL
    or  upper(subfield) like '%ERRAT%' --includes ERRATUM
    or  upper(subfield) like '%FINDING AID%' --includes FINDING AIDS
    or  upper(subfield) like '%GUIDE%' --includes GUIDES
    or  upper(subfield) like '%INDEX%' --includes INDEXES
    or  upper(subfield) like '%INDICES%'
    or  upper(subfield) like '%RELATED%'
    or  upper(subfield) like '%UPDATE%' --includes UPDATES
    or  upper(subfield) like '%USER AID%'
    or  upper(subfield) like '%USER''S AID%'
  )
  -- 3373 after exclusions
  -- Random sample if needed
  ---order by dbms_random.value
  --fetch first 50 rows only
)
--select count(*) from bibs;
select
  b.record_id as bib_id
, b.indicators
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
