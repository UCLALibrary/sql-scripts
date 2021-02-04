/*  Bib 856 $x not on approved list.
    RR-647
*/

select 
  bs.record_id as bib_id
, bs.subfield as f856x
, vger_subfields.getfieldfromsubfields(bs.record_id, bs.field_seq) as full_856
from vger_subfields.ucladb_bib_subfield bs
inner join bib_master bm on bs.record_id = bm.bib_id and bm.suppress_in_opac = 'N'
where bs.tag = '856x'
-- Officially OK
and bs.subfield not in ('UCLA', 'UCLA Clark', 'UCLA Law', 'CDL', 'UC open access')
-- Unofficially OK?
--and bs.subfield not in ('UCLA.')
order by bs.record_id
;
