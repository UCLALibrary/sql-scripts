/*  Oral History records for OH-24

300 $a contains "online resource"
710 $b contains "Center for Oral History Research"
655 $a contains "oral histories"
Bib record contains an 856 with indicators 40. 
*/

select
  s710b.record_id as bib_id
from vger_subfields.ucladb_bib_subfield s710b
inner join vger_subfields.ucladb_bib_subfield s655a
  on s710b.record_id = s655a.record_id
inner join vger_subfields.ucladb_bib_subfield s300a
  on s655a.record_id = s300a.record_id
where s710b.tag = '710b'
and s710b.subfield like '%Center for Oral History Research%' -- 123
and s655a.tag = '655a'
and s655a.subfield like '%oral histories%' -- 119
and s300a.tag = '300a'
and s300a.subfield like '%online resource%' -- 36
and exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = s710b.record_id
  and tag like '856%'
  and indicators = '40'
) -- 36
order by bib_id
;