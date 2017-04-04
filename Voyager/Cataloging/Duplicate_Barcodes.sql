-- Duplicate item barcodes
with dups as (
  select * 
  from item_barcode
  where item_barcode in
    (select item_barcode from item_barcode group by item_barcode having count(*) > 1)
)
select 
  d.item_barcode
, ibs.barcode_status_desc as status
, d.barcode_status_date
, bm.bib_id
, bm.mfhd_id
, d.item_id
, substr(bt.bib_format, 2, 1) as format
, mi.item_enum
, l.location_code
, mm.display_call_no
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title_brief
from dups d
inner join mfhd_item mi on d.item_id = mi.item_id
inner join item_barcode_status ibs on d.barcode_status = ibs.barcode_status_type
inner join mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
order by d.item_barcode, d.barcode_status_date
;

