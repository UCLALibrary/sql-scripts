/*  Bib 856 fields for various non-text links
    SILSLA-81
*/

with bibs as (
  select distinct
    record_id
  , field_seq
  , replace(indicators, ' ', '_') as indicators
  , replace(substr(indicators, 2, 1), ' ', '_') as ind2
  from vger_subfields.ucladb_bib_subfield
  where (tag like '856%' and tag not in ('856u', '856x'))
  and ( 1=0
    or  upper(subfield) like '%ABSTRACT%'
    or  upper(subfield) like '%AVAILABLE TO STANFORD%'
    or  upper(subfield) like '%BACK COVER%'
    or  upper(subfield) like '%BOOK COVER%'
    or  upper(subfield) like '%BOOK REVIEW%'
    or  upper(subfield) like '%BUCHCOVER%'
    or  upper(subfield) like '%CONTRIBUTOR BIOGRAPHICAL INFORMATION%'
    or  upper(subfield) like '%COVER IMAGE%'
    or  upper(subfield) like '%DESCRIPTION%'
    or  upper(subfield) like '%FOREWORD%'
    or  upper(subfield) like '%INHALTS%'
    or  upper(subfield) like '%INTRODUCTION%'
    or  upper(subfield) like '%LP COVER%'
    or  upper(subfield) like '%SAMPLE%'
    or  upper(subfield) like '%SUMMAR%'
    or  upper(subfield) like '%TABLE OF CONTENTS%'
    or  upper(subfield) like '%TABLES OF CONTENTS%'
    or  upper(subfield) like '%TITLE PAGE%'
    or  subfield like '%TOC%' --upper-case only
  )
  minus
  select distinct
    record_id
  , field_seq
  , replace(indicators, ' ', '_') as indicators
  , replace(substr(indicators, 2, 1), ' ', '_') as ind2
  from vger_subfields.ucladb_bib_subfield
  where (tag like '856%' and tag not in ('856u', '856x'))
  and ( 1=0
    or  upper(subfield) like '%ADDITION%'
    or  upper(subfield) like '%AVAILABLE ISSUE%'
    or  upper(subfield) like '%CHAPTER%'
    or  upper(subfield) like '%CURRENT ISSUE%'
    or  upper(subfield) like '%ERRAT%'
    or  upper(subfield) like '%FINDING AID%'
    or  upper(subfield) like '%FULL REPORT%'
    or  upper(subfield) like '%FULL-TEXT%'
    or  upper(subfield) like '%FULL TEXT%'
    or  upper(subfield) like '%GUIDE%'
    or  upper(subfield) like '%INDEX%'
    or  upper(subfield) like '%INDICES%'
    or  upper(subfield) like '%LATEST ISSUE%'
    or  upper(subfield) like '%ONLINE ARCHIVE OF CALIFORNIA%'
    or  upper(subfield) like '%RELATED%'
    or  upper(subfield) like '%REPORT%'
    or  upper(subfield) like '%SELECTED%'
    or  upper(subfield) like '%SUPPLEMENT%'
    or  upper(subfield) like '%UPDATE%'
    or  upper(subfield) like '%USER AID%'
    or  upper(subfield) like '%USER''S AID%'
  )
)
--select count(*) from bibs; --122407
select
  b.record_id as bib_id
, b.indicators
, b.ind2
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = b.record_id
) as locs
, vger_subfields.getfieldfromsubfields(b.record_id, b.field_seq) as f856
from bibs b
where b.record_id <= 2000
order by bib_id
;


-- Query for program
with bibs as (
  select distinct
    record_id
  from vger_subfields.ucladb_bib_subfield
  where (tag like '856%' and tag not in ('856u', '856x'))
  and ( 1=0
    or  upper(subfield) like '%ABSTRACT%'
    or  upper(subfield) like '%AVAILABLE TO STANFORD%'
    or  upper(subfield) like '%BACK COVER%'
    or  upper(subfield) like '%BOOK COVER%'
    or  upper(subfield) like '%BOOK REVIEW%'
    or  upper(subfield) like '%BUCHCOVER%'
    or  upper(subfield) like '%CONTRIBUTOR BIOGRAPHICAL INFORMATION%'
    or  upper(subfield) like '%COVER IMAGE%'
    or  upper(subfield) like '%DESCRIPTION%'
    or  upper(subfield) like '%FOREWORD%'
    or  upper(subfield) like '%INHALTS%'
    or  upper(subfield) like '%INTRODUCTION%'
    or  upper(subfield) like '%LP COVER%'
    or  upper(subfield) like '%SAMPLE%'
    or  upper(subfield) like '%SUMMAR%'
    or  upper(subfield) like '%TABLE OF CONTENTS%'
    or  upper(subfield) like '%TABLES OF CONTENTS%'
    or  upper(subfield) like '%TITLE PAGE%'
    or  subfield like '%TOC%' --upper-case only
  )
  minus
  select distinct
    record_id
  from vger_subfields.ucladb_bib_subfield
  where (tag like '856%' and tag not in ('856u', '856x'))
  and ( 1=0
    or  upper(subfield) like '%ADDITION%'
    or  upper(subfield) like '%AVAILABLE ISSUE%'
    or  upper(subfield) like '%CHAPTER%'
    or  upper(subfield) like '%CURRENT ISSUE%'
    or  upper(subfield) like '%ERRAT%'
    or  upper(subfield) like '%FINDING AID%'
    or  upper(subfield) like '%FULL REPORT%'
    or  upper(subfield) like '%FULL-TEXT%'
    or  upper(subfield) like '%FULL TEXT%'
    or  upper(subfield) like '%GUIDE%'
    or  upper(subfield) like '%INDEX%'
    or  upper(subfield) like '%INDICES%'
    or  upper(subfield) like '%LATEST ISSUE%'
    or  upper(subfield) like '%ONLINE ARCHIVE OF CALIFORNIA%'
    or  upper(subfield) like '%RELATED%'
    or  upper(subfield) like '%REPORT%'
    or  upper(subfield) like '%SELECTED%'
    or  upper(subfield) like '%SUPPLEMENT%'
    or  upper(subfield) like '%UPDATE%'
    or  upper(subfield) like '%USER AID%'
    or  upper(subfield) like '%USER''S AID%'
  )
)
--select count(*) from bibs; --122407
select
  b.record_id as bib_id
from bibs b
where b.record_id <= 2000 -- TESTING
order by bib_id
;
