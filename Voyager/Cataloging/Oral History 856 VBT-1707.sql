/*  Records with UCLA Oral History URLs.
    VBT-1707.
*/

-- The right place, $u
with bibs as (
  select 
    record_id as bib_id
  , subfield as url
  from vger_subfields.ucladb_bib_subfield 
  where tag = '856u'
  and lower(subfield) like '%//oralhistory.library.ucla.edu%'
)
select
  b.bib_id
, b.url
, vger_support.unifix(bt.title) as title
from bibs b
inner join bib_text bt on b.bib_id = bt.bib_id
order by b.bib_id
;

-- Some have the wrong place, $a
with bibs as (
  select 
    record_id as bib_id
  , subfield as url
  from vger_subfields.ucladb_bib_subfield 
  where tag = '856a'
  and lower(subfield) like '%//oralhistory.library.ucla.edu%'
)
select
  b.bib_id
, b.url
, vger_support.unifix(bt.title) as title
from bibs b
inner join bib_text bt on b.bib_id = bt.bib_id
order by b.bib_id
;
