/*  Samples of bib 69x data.
    VBT-1765
*/

-- Bib data from 69x fields
with d as (
  select distinct
    substr(tag, 1, 3) as tag
  , substr(indicators, 2, 1) as ind2
  , record_id as bib_id
  , field_seq
  , case
      when indicators like '%7'
      then (  select subfield from vger_subfields.ucladb_bib_subfield
              where record_id = bs.record_id and field_seq = bs.field_seq and tag like '%2'
              and rownum < 2
          )
      else null
  end as sfd2
  , vger_subfields.getfieldfromsubfields(record_id, field_seq) as full_field
  from vger_subfields.ucladb_bib_subfield bs
  where tag like '69%'
  --and record_id between 1 and 1000 --- TESTING ---
)
-- Add row number 1..N, for each partition of tag / ind 2 / $2, randomly ordered
, rws as (
  select 
    d.* 
  , row_number() over (
    partition by tag, ind2, sfd2
    order by dbms_random.value
  ) as row_num
  from d
)
, field_counts as (
  -- Add counts before limiting by number of rows
  select
    tag
  , ind2
  , sfd2
  , count(*) over (partition by tag, ind2, sfd2) fld_count
  , row_num
  , bib_id
  , full_field
  from rws
)
-- Data for reporting: Select up to 3 rows for each tag / ind2 / $2 combination
select
  tag
, ind2
, sfd2
, fld_count
, bib_id
, full_field
from field_counts
where row_num <= 3
order by tag, ind2, sfd2, bib_id
;

