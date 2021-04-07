/*  CDL POs with no attached invoices.
    VBT-1763
*/

select distinct
  po.po_id
, bt.bib_id
, po.po_number
, pon.note as po_note
, vger_support.unifix(bt.title) as title
, lin.note as line_note
from purchase_order po
inner join po_type pot on po.po_type = pot.po_type
inner join po_status pos on po.po_status = pos.po_status
inner join vendor v on po.vendor_id = v.vendor_id
inner join line_item li on po.po_id = li.po_id
inner join bib_text bt on li.bib_id = bt.bib_id
left outer join po_notes pon on po.po_id = pon.po_id
left outer join line_item_notes lin on li.line_item_id = lin.line_item_id
where v.vendor_code = 'LXO'
-- No invoice lines for any po line on this order
and not exists (
  select * from invoice_line_item
  where line_item_id in (select line_item_id from line_item where po_id = po.po_id)
)
order by po_number, po_id
;
-- 20 POs have no invoices at all
