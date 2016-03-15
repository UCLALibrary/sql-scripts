
select    DISTINCT
  bt.title
, fvw.fiscal_period_name
, fvw.ledger_name
, i.invoice_number
--, i.invoice_date
, TO_CHAR(i.invoice_date,'fmMM/ DD/ YYYY')  inv_date
, f.fund_code
, ili.line_price/100 AS cost
--, bt.bib_id
--, mm.mfhd_id
--, mm.display_call_no
--, bt.title AS title
--, po_create_date
, po.po_number
, pot.po_type_desc
--, po_create_date
, TO_CHAR(po_create_date,'fmMM/ DD/ YYYY')  po_create_date
--, ist.invoice_status_desc
--, lit.line_item_type_desc
--, lis.LINE_ITEM_STATUS_desc
--, fvw.ledger_name

--, v.vendor_name
--, l.location_name
--, TO_CHAR(i.invoice_date,'fmMM/ DD/ YYYY')  last_inv_date
--, (ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate)) as last_payment_amount
--, vger_support.get_fiscal_period(i.invoice_status_date) as fiscal_year
from ucladb.purchase_order po
inner join ucladb.vendor v on po.vendor_id = v.vendor_id
inner join ucladb.po_status pos on po.po_status = pos.po_status
INNER JOIN ucladb.PO_TYPE pot ON po.PO_TYPE = pot.PO_TYPE
inner join ucladb.line_item li on po.po_id = li.po_id
INNER JOIN LINE_ITEM_TYPE lit ON li.LINE_ITEM_TYPE = lit.LINE_ITEM_TYPE
inner join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
INNER JOIN LINE_ITEM_STATUS lis ON lics.LINE_ITEM_STATUS = lis.LINE_ITEM_STATUS

inner join location l on po.order_location = l.location_id
inner join location l on lics.location_id = l.location_id
inner join ucladb.line_item_funds lif on lics.copy_id = lif.copy_id
inner join ucladb.fund f on lif.ledger_id = f.ledger_id and lif.fund_id = f.fund_id
left OUTER JOIN FUNDLEDGER_VW fvw ON f.LEDGER_ID = fvw.LEDGER_ID

inner join ucladb.bib_text bt on li.bib_id = bt.bib_id
inner JOIN BIB_MFHD bm ON bt.BIB_ID = bm.BIB_ID
INNER JOIN MFHD_MASTER mm ON bm.MFHD_ID = mm.MFHD_ID

inner join ucladb.invoice_line_item ili on li.line_item_id = ili.line_item_id
INNER join ucladb.invoice i on ili.invoice_id = i.invoice_id
INNER join ucladb.invoice_status ist on i.invoice_status = ist.invoice_status
where v.vendor_code = 'ASU'
    --  AND lit.line_item_type_desc = 'Single-part'
      AND ist.invoice_status_desc = 'Approved'
      AND lis.LINE_ITEM_STATUS_desc = 'Received Complete'
      AND fvw.ledger_name = 'College 14-15'

