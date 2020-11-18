/*  Sampling of bib records with $5 CLU variants.
    SILSLA-38.
*/

-- Occurrences by value
with bibs as (
  select 
    record_id as bib_id
  , substr(tag, 1, 3) as tag
  , subfield
  from vger_subfields.ucladb_bib_subfield
  where tag like '%5'
  and subfield like 'CLU%'
)
select subfield, count(*) as occ 
from bibs 
group by subfield 
order by subfield
;

-- Occurrences by tag
with bibs as (
  select 
    record_id as bib_id
  , substr(tag, 1, 3) as tag
  , subfield
  from vger_subfields.ucladb_bib_subfield
  where tag like '%5'
  and subfield like 'CLU%'
)
, samples as (
  select
    tag
  , count(*) as uses
  , min(bib_id) as min_bib
  , max(bib_id) as max_bib
  from bibs b
  group by tag
)
select 
  tag
, uses
, min_bib
, max_bib
, (select bib_id from bibs where tag = s.tag and s.min_bib < bib_id and bib_id < s.max_bib and rownum < 2) as middle_bib
from samples s
order by tag
;

