SELECT DISTINCT
  f.fund_code
, ili.line_price/100 AS line_total
--, bt.bib_id
--, mm.mfhd_id
--, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'b') AS f852b
--, mm.display_call_no
, bt.title AS title
, po.po_number
, lit.line_item_type_desc
--, v.vendor_code
--, l.location_name
--, i.invoice_update_date
--, TO_CHAR(i.invoice_update_date,'fmMM/ DD/ YYYY')
--, TO_CHAR(i.invoice_date,'FMMM/DD/YYYY')  last_inv_date
--, i.invoice_date as last_inv_date_REAL
--, i.invoice_number
, ili.piece_identifier

from ucladb.purchase_order po

inner join ucladb.vendor v on po.vendor_id = v.vendor_id
--INNER JOIN PO_TYPE pot ON po.PO_TYPE = pot.PO_TYPE
--inner join ucladb.po_status pos on po.po_status = pos.po_status
inner join ucladb.line_item li on po.po_id = li.po_id
inner join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
 INNER JOIN LINE_ITEM_TYPE lit ON li.LINE_ITEM_TYPE = lit.LINE_ITEM_TYPE
--inner join location l on po.ship_location = l.location_id
inner join ucladb.line_item_funds lif on lics.copy_id = lif.copy_id
INNER JOIN LEDGER le ON lif.LEDGER_ID = le.LEDGER_ID
inner join ucladb.fund f on lif.ledger_id = f.ledger_id and lif.fund_id = f.fund_id
inner join ucladb.bib_text bt on li.bib_id = bt.bib_id
--inner JOIN BIB_MFHD bm ON bt.BIB_ID = bm.BIB_ID
--INNER JOIN MFHD_MASTER mm ON bm.MFHD_ID = mm.MFHD_ID
INNER join ucladb.invoice_line_item ili on li.line_item_id = ili.line_item_id
INNER join ucladb.invoice i on ili.invoice_id = i.invoice_id

WHERE v.vendor_code = 'LXO'
    AND (i.invoice_number = 'UCLARCHG17Q1.july-sept'
      OR i.invoice_number = 'UCLARCHG17Q2.oct-dec'
      OR i.invoice_number = 'UCLARCHG17Q3.apr'
      OR i.invoice_number = 'UCLARCHG17Q3.mar'
      OR i.invoice_number = 'UCLARCHG17Q3.out oct-mar'
      OR i.invoice_number = 'UCLARCHG17Q3.sep-feb'
      OR i.invoice_number = 'UCLARCHG17Q4.may'
      OR i.invoice_number = 'UCLARCHG17Q5.may')


AND i.invoice_update_date BETWEEN to_date('2016-07-01', 'YYYY-MM-DD') and to_date('2017-06-30', 'YYYY-MM-DD')

ORDER BY bt.title;
