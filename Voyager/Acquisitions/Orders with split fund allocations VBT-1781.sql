/*  Orders with extended (split, multiple) fund allocations.
    VBT-1781
*/

select
  po.po_number
, lis.line_item_status_desc as line_status
, pos.po_status_desc as po_status
, pot.po_type_desc as po_type
, l.location_code
, f.ledger_name
, f.fund_name
, f.fund_code
, round((lif.percentage / 1000000), 2) as percentage 
, ucladb.tobasecurrency(lif.amount, po.currency_code) as usd_amount
, lif.allocation_method as method
, li.bib_id
, vger_support.unifix(bt.title) as title
from line_item_funds lif
inner join ucla_fundledger_vw f on lif.ledger_id = f.ledger_id and lif.fund_id = f.fund_id
inner join line_item_copy_status lics on lif.copy_id = lics.copy_id
inner join line_item li on lics.line_item_id = li.line_item_id
inner join purchase_order po on li.po_id = po.po_id
inner join po_status pos on po.po_status = pos.po_status
inner join po_type pot on po.po_type = pot.po_type
inner join line_item_status lis on lics.line_item_status = lis.line_item_status
inner join bib_text bt on li.bib_id = bt.bib_id
inner join location l on lics.location_id = l.location_id
where lif.percentage != 100000000
and pos.po_status_desc in ('Approved/Sent', 'Received Partial')
order by po.po_id, f.ledger_name, f.fund_name
;