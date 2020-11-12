/*  Queries for monographic ghost holdings recordd cleanup.
    VBT-1702
*/

-- Monographic ghost holdings records to delete
select distinct mm.mfhd_id --count(distinct mm.mfhd_id)
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code like '%sr' 
and l.location_code not in ('sr', 'uclsr')
and substr(bt.bib_format, 2, 1) not in ('b', 'i', 's')
order by mm.mfhd_id
;

-- Items attached
select distinct
  mm.mfhd_id
, l.location_code
, mi.item_enum
, ib.item_barcode
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join item_barcode ib on mi.item_id = ib.item_id and ib.barcode_status = 1
where l.location_code like '%sr' 
and l.location_code not in ('sr', 'uclsr')
and substr(bt.bib_format, 2, 1) not in ('b', 'i', 's')
order by item_barcode
;

-- Orders attached
select distinct
  mm.mfhd_id
, l.location_code
, po.po_number
, pos.po_status_desc as status
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
inner join line_item_copy_status lics on mm.mfhd_id = lics.mfhd_id
inner join line_item li on lics.line_item_id = li.line_item_id
inner join purchase_order po on li.po_id = po.po_id
inner join po_status pos on po.po_status = pos.po_status
where l.location_code like '%sr' 
and l.location_code not in ('sr', 'uclsr')
and substr(bt.bib_format, 2, 1) not in ('b', 'i', 's')
order by location_code, po_number
;