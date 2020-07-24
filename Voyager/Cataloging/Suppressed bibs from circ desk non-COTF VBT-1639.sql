/*  Suppressed bibs with no holdings, created at circ desk, without COTF in 245 $a.
    VBT-1639
*/

select 
  b.bib_id
, l.location_code
, vger_support.unifix(bt.title_brief) as title_brief
from bib_master b
inner join bib_history bh on b.bib_id = bh.bib_id and bh.action_type_id = 1 --Created
inner join location l on bh.location_id = l.location_id
left outer join bib_text bt on b.bib_id = bt.bib_id
where b.suppress_in_opac = 'Y'
and l.location_code like '%loan%'
and not exists ( 
  select *
  from bib_mfhd
  where bib_id = b.bib_id
)
and not exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = b.bib_id
  and tag = '245a'
  and subfield like '%COTF%'
)
order by l.location_code, b.bib_id
;