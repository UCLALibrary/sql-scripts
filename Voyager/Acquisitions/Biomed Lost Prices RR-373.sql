/*  Report on costs (where possible) of items provided via spreadsheet, imported into temporary table.
    RR-373
*/
select
  r.title
, r.perm_location
, r.call_no
, r.barcode
, r.copy
, bm.*
, ilif.amount / 100 as usd_amount
, i.invoice_number
from vger_report.tmp_rr_373 r
left outer join ucladb.item_barcode ib on r.barcode = ib.item_barcode
left outer join ucladb.mfhd_item mi on ib.item_id = mi.item_id
left outer join ucladb.bib_mfhd bm on mi.mfhd_id = bm.mfhd_id
left outer join ucladb.line_item_copy_status lics on mi.mfhd_id = lics.mfhd_id
--left outer join ucladb.line_item li on lics.line_item_id = li.line_item_id
left outer join ucladb.invoice_line_item_funds ilif on lics.copy_id = ilif.copy_id
left outer join ucladb.invoice_line_item ili on ilif.inv_line_item_id = ili.inv_line_item_id
left outer join ucladb.invoice i on ili.invoice_id = i.invoice_id
order by r.barcode, bm.mfhd_id
;

-- Clean up after report
drop table vger_report.tmp_rr_373 purge;