SELECT DISTINCT
f.ledger_name,
--f.fund_code,
--po.po_number,
--bt.TITLE,
--bt.publisher,
--v.vendor_name,
--po.currency_code,
--lis.LINE_ITEM_STATUS_desc,
--line_item.line_price/100 AS committment,
ili.line_price/100 AS Inv_line_price,
--i.invoice_number,
--ist.invoice_status_desc,
--i.invoice_update_date AS inv_status_date,
TO_CHAR(i.invoice_update_date,'fmMM/ DD/ YYYY')  inv_status_date
--lit.line_item_type_desc



from ucla_fundledger_vw f
--INNER JOIN INVOICE_LINE_ITEM_FUNDS ilif ON FUNDLEDGER_VW.LEDGER_ID = INVOICE_LINE_ITEM_FUNDS.LEDGER_ID
-- INNER JOIN ucla_fundledger_vw f ON
inner join invoice_line_item_funds ilif
  on f.ledger_id = ilif.ledger_id
  and f.fund_id = ilif.fund_id
inner join invoice_line_item ili on ilif.inv_line_item_id = ili.inv_line_item_id
inner join line_item li on ili.line_item_id = li.line_item_id
 INNER JOIN LINE_ITEM_TYPE lit ON li.LINE_ITEM_TYPE = lit.LINE_ITEM_TYPE
INNER JOIN LINE_ITEM_COPY_STATUS lic ON li.LINE_ITEM_ID = lic.LINE_ITEM_ID
INNER JOIN LINE_ITEM_STATUS lis ON lic.LINE_ITEM_STATUS = lis.LINE_ITEM_STATUS

INNER JOIN PURCHASE_ORDER po ON li.PO_ID = po.PO_ID
INNER JOIN VENDOR v ON po.VENDOR_ID = v.VENDOR_ID

inner join ucla_bibtext_vw bt on li.bib_id = bt.bib_id
inner join invoice i on ili.invoice_id = i.invoice_id
inner join invoice_status ist on i.invoice_status = ist.invoice_status


WHERE --invoice.invoice_status_date BETWEEN to_date('20150629', 'YYYYMMDD') AND to_date('20160530', 'YYYYMMDD')
         ist.invoice_status_desc = 'Approved'
        AND lit.line_item_type_desc = 'Subscription'
        AND (lis.LINE_ITEM_STATUS_desc = 'Approved' OR lis.LINE_ITEM_STATUS_desc = 'Received Complete')
        AND --f.ledger_name =  'ARTS 15-16'
         -- OR f.ledger_name = 'BIOMED 15-16'
         -- OR f.ledger_name = 'MUSIC 15-16'
         -- OR f.ledger_name = 'CRIS 15-16'
         -- OR f.ledger_name = 'COLLEGE 15-16'
         -- OR f.ledger_name = 'EAST ASIAN 15-16'
         -- OR f.ledger_name = 'SEL 15-16'
          --OR
          f.ledger_name = 'MANAGEMENT 15-16'--)

        AND i.invoice_update_date BETWEEN to_date('20150629', 'YYYYMMDD') AND to_date('20160530', 'YYYYMMDD')

        ORDER BY f.ledger_name

