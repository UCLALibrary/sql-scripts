/*  Geology Maps data
    RR-390
*/

select 
  l.location_code
, l.location_name
--, mm.normalized_call_no
, mm.display_call_no as call_number
, mi.item_enum
, i.copy_number as copy_no
, vger_support.get_all_item_status(mi.item_id) as item_status
, bt.bib_id
, bt.lccn
, ( select replace(normal_heading, 'UCOCLC') from bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
) as oclc
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, replace(vger_support.unifix(ucladb.GetMarcField(bm.bib_id, 0, 0, '255 507', '', 'abcdefg')), 'NOT FOUND', '') as map_info
, vger_support.unifix(bt.imprint) as imprint
, replace(vger_support.unifix(ucladb.GetMarcField(bm.bib_id, 0, 0, '300', '', 'abc')), 'NOT FOUND', '') as phys_desc
, vger_support.get_subjects(bt.bib_id) as all_subjects
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
-- Some holdings have no items
left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join item i on mi.item_id = i.item_id
where l.location_code in ('sgput', 'sgputmaps', 'sgputshe')
order by l.location_code, mm.normalized_call_no, mi.item_enum, i.copy_number
;


