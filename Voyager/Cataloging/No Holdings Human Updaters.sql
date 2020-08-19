/*  Bib records with no holdings, including the most recent
    non-automated operator updating the record.
    VBT-1653
*/

with bibs as (
  select 
    br.bib_id
  from bib_master br
  where not exists (
    select * from bib_mfhd
    where bib_id = br.bib_id
  )
)
select 
  b.bib_id
, l.location_name
, bh.action_date
, bh.operator_id
, trim(o.first_name || ' ' || o.last_name) as operator_name
from bibs b
inner join bib_history bh on b.bib_id = bh.bib_id
left outer join location l on bh.location_id = l.location_id
left outer join operator o on bh.operator_id = o.operator_id
where action_date = (
  select max(action_date)
  from bib_history
  where bib_id = b.bib_id
  and operator_id not in ('load', 'lisprogram', 'scploader', 'marsloader', 'uclaloader', 'nomelvyl', 'GLOBAL', 'promptcat')
)
order by b.bib_id
;
