/*  Silent films report for FATA.
    Records with 
    * 655 $a Silent films.
    * No 520 field
    VBT-1582
*/

select distinct -- 1 dup record/field
  bt.bib_id
, vger_support.unifix(bt.title_brief) as title_brief
from vger_subfields.filmntvdb_bib_subfield bs
inner join filmntvdb.bib_text bt on bs.record_id = bt.bib_id
where bs.tag = '655a'
and bs.subfield = 'Silent films.'
and not exists (
  select *
  from vger_subfields.filmntvdb_bib_subfield
  where record_id = bs.record_id
  and tag like '520%'
)
order by bt.bib_id
;
-- 8348 bibs with that 655 $a, with 1 extra fieid? Bib 6520 has dup 655, report to FATA
-- 5245 bibs after excluding 520 field

