/*  Bib 856 $u not starting with http.
    RR-592
*/

select 
  bs.record_id as bib_id
, bs.subfield as f856u
--, vger_subfields.getfieldfromsubfields(bs.record_id, bs.field_seq) as full_856
, ( select subfield from vger_subfields.ucladb_bib_subfield 
    where record_id = bs.record_id
    and field_seq = bs.field_seq
    and tag = '856x'
    --and upper(subfield) like '%LAW%'
    and rownum < 2
) as f856x
, vger_support.unifix(bt.title_brief) as title_brief
from vger_subfields.ucladb_bib_subfield bs
inner join bib_text bt on bs.record_id = bt.bib_id
where bs.tag = '856u'
and bs.subfield not like 'http%'
order by bs.record_id
;
-- 848 856 $u -- bib 7521456 has 7_