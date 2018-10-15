/*  LGBT Inventory
    RR-398
*/
select
  l.location_code
, mm.display_call_no
, bm.bib_id
, bm.mfhd_id
, bt.isbn
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title_brief
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
where l.location_code like 'lg%'
order by l.location_code, mm.normalized_call_no
;

