/*  Bib records for escholarship, with no OCLC number.
    VBT-1679
*/

with bibs as (
  select distinct 
    record_id as bib_id
  , subfield as f856u
  from vger_subfields.ucladb_bib_subfield bs
  where tag = '856u'
  and lower(subfield) like '%escholarship%' --5273
  and not exists (
    select *
    from bib_index
    where bib_id = bs.record_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
  ) --5273
)
select
  b.bib_id
, b.f856u
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, ucladb.GetAllBibTag(b.bib_id, '793', 2) as f793
from bibs b
inner join bib_text bt on b.bib_id = bt.bib_id
order by b.bib_id
;

