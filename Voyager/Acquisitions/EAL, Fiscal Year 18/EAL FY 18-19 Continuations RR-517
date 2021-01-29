select  
 le.ledger_name
, i.invoice_number
, f.fund_code
--i.invoice_status_date as purchase_date
--  To_Char (i.invoice_status_date,'fmMM/ DD/ YYYY') AS purchase_date
, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) as purchase_price
, bt.title
, po.po_number
, pot.po_type_desc
--, Sum(ili.line_price/100) AS cost
--, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) as usd_amt
--, i.invoice_status_date as paid_date
, vger_support.get_fiscal_period(i.invoice_status_date) as fiscal_year

from ucladb.purchase_order po
inner join ucladb.vendor v on po.vendor_id = v.vendor_id
inner join ucladb.po_status pos on po.po_status = pos.po_status
INNER JOIN PO_TYPE pot ON po.PO_TYPE = pot.PO_TYPE
inner join ucladb.line_item li on po.po_id = li.po_id
inner join ucladb.line_item_type lit on li.line_item_type = lit.line_item_type
inner join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
inner join location l on lics.location_id = l.location_id
inner join ucladb.line_item_funds lif on lics.copy_id = lif.copy_id
inner join ucladb.fund f on lif.ledger_id = f.ledger_id and lif.fund_id = f.fund_id
inner join FUNDLEDGER_VW le on lif.ledger_id = le.ledger_id
inner join ucladb.bib_text bt on li.bib_id = bt.bib_id
INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
left outer join ucladb.invoice_line_item ili on li.line_item_id = ili.line_item_id
left outer join ucladb.invoice i on ili.invoice_id = i.invoice_id
left outer join ucladb.invoice_status ist on i.invoice_status = ist.invoice_status
where --le.ledger_name = 'EAST ASIAN 18-19' 
--and 
(     (SubStr (f.FUND_CODE, 2,1) = '2')
 OR   (SubStr (f.FUND_CODE, 2,1) = '1') )
 
and ((SubStr (f.FUND_CODE, 3,1) = 'S')
OR   (SubStr (f.FUND_CODE, 3,1) = 'M')
OR   (SubStr (f.FUND_CODE, 3,1) = 'D'))

and ((SubStr (f.FUND_CODE, 7,1) = 'E')
and  (SubStr (f.FUND_CODE, 8,1) = 'A'))
--R   (SubStr (f.FUND_CODE, 9,1) = 'L'))


and ((SubStr (f.FUND_CODE, 9,1) = 'J')
OR   (SubStr (f.FUND_CODE, 9,1) = 'C')
OR   (SubStr (f.FUND_CODE, 9,1) = 'L'))

AND le.FUND_CATEGORY = 'Reporting'
and pot.po_type_desc = 'Continuation'


 and i.invoice_status_date between to_date('20180701', 'YYYYMMDD') and to_date('20190630', 'YYYYMMDD')
 
 group by
  le.ledger_name
, i.invoice_number
, f.fund_code
, i.invoice_status_date
--  To_Char (i.invoice_status_date,'fmMM/ DD/ YYYY') AS purchase_date
, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) 
, po.po_number
, pot.po_type_desc
, ili.line_price/100
, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) 
--, i.invoice_status_date as paid_date
, vger_support.get_fiscal_period(i.invoice_status_date) 
, bt.title



order by f.fund_code, i.invoice_number
--mm.normalized_call_no 
--po.po_number
--order by bt.title, i.invoice_status_date
