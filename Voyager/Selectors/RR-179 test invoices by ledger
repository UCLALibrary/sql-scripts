
select DISTINCT
  f.ledger_name
--, vger_support.get_fiscal_period(i.invoice_status_date) as fiscal_year
, ucladb.toBaseCurrency(li.line_price, i.currency_code, i.conversion_rate) AS committment

, po.po_number
, po.currency_code
, pos.po_status_desc
, lit.line_item_type_desc AS li_type
--, pon.print_note
--, li.line_price AS committment
, v.vendor_code
, f.fund_code

, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) AS inv_amt --line_price
--, ili.piece_identifier
--, ucladb.getbibtag(bt.Bib_id, '022') AS f022
, bt.title as title
, bt.publisher
, ucladb.getbibtag(bt.Bib_id, '856') AS f856
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'b') AS f852b
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'h') AS f852h
, bt.bib_id
, pon.note
from ucla_fundledger_vw f

inner join invoice_line_item_funds ilif
  on f.ledger_id = ilif.ledger_id
  and f.fund_id = ilif.fund_id
inner join invoice_line_item ili on ilif.inv_line_item_id = ili.inv_line_item_id
inner join line_item li on ili.line_item_id = li.line_item_id
 INNER JOIN LINE_ITEM_TYPE lit ON li.LINE_ITEM_TYPE = lit.LINE_ITEM_TYPE
INNER JOIN LINE_ITEM_COPY_STATUS lic ON li.LINE_ITEM_ID = lic.LINE_ITEM_ID
INNER JOIN LINE_ITEM_STATUS lis ON lic.LINE_ITEM_STATUS = lis.LINE_ITEM_STATUS

INNER JOIN PURCHASE_ORDER po ON li.PO_ID = po.PO_ID
INNER JOIN PO_TYPE pot ON po.PO_TYPE = pot.PO_TYPE
INNER JOIN PO_STATUS pos ON po.PO_STATUS = pos.PO_STATUS
left OUTER JOIN PO_NOTES pon ON po.PO_ID = pon.PO_ID

INNER JOIN VENDOR v ON po.VENDOR_ID = v.VENDOR_ID

inner join ucla_bibtext_vw bt on li.bib_id = bt.bib_id

INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID

inner join invoice i on ili.invoice_id = i.invoice_id
inner join invoice_status ist on i.invoice_status = ist.invoice_status


WHERE

    f.ledger_name LIKE 'SEL%'
    AND i.invoice_status_date BETWEEN to_date('20130701', 'YYYYMMDD') AND to_date('20160630', 'YYYYMMDD')
    


 AND    pot.po_type_desc = 'Continuation'

and (pos.po_status_desc in ('Approved/Sent', 'Received Complete', 'Received Partial')
         AND pos.po_status_desc NOT in ('Canceled') )


          ORDER BY bt.title, f.ledger_name
