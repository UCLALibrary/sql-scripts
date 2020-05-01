/*  One-time e-resource orders
    VBT-1590
*/

select
  li.bib_id
--, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = li.bib_id and tag = '245a' and rownum < 2) as f245a
, vger_support.unifix(bt.title_brief) as title_brief
, ucladb.tobasecurrency(li.line_price, po.currency_code, po.conversion_rate) as list_usd
, po.po_approve_date as order_date
, v.vendor_code
, po.po_number
, pos.po_status_desc
, pot.po_type_desc
from purchase_order po
inner join po_status pos on po.po_status = pos.po_status
inner join po_type pot on po.po_type = pot.po_type
inner join vendor v on po.vendor_id = v.vendor_id
inner join line_item li on po.po_id = li.po_id
inner join line_item_copy_status lics on li.line_item_id = lics.line_item_id
inner join mfhd_master mm on lics.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join bib_text bt on li.bib_id = bt.bib_id
where po.po_approve_date >= to_date('20200301', 'YYYYMMDD')
and pot.po_type_desc in ('Firm Order', 'Approval')
and l.location_code = 'in'
order by order_date, vendor_code, po_number
;