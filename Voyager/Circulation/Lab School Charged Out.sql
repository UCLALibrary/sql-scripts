select
  (select patron_barcode from patron_barcode where patron_id = ct.patron_id and barcode_status = 1 and rownum < 2) as patron_barcode
, pa.address_line1 as email
, ct.charge_date
, ct.current_due_date
, ib.item_barcode
, mi.item_enum
, vger_support.get_all_item_status(ct.item_id) as item_status
, mm.display_call_no
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title_brief
from circ_transactions ct
inner join mfhd_item mi on ct.item_id = mi.item_id
inner join mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
left outer join item_barcode ib on ct.item_id = ib.item_id and ib.barcode_status = 1 --Active
left outer join patron_address pa on ct.patron_id = pa.patron_id and pa.address_type = 3 --Email
where l.location_code like 'ue%'
order by patron_barcode, charge_date, current_due_date
;

select * from patron_barcode_status;
select * from patron_group where patron_group_id < 5;