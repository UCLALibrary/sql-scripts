SELECT DISTINCT
ft.fund_type_name,
f.fund_name,
f.institution_fund_id,
f.fund_code,
bt.title,
bt.author,
bt.publisher,
bt.publisher_date,
   -- i.invoice_number,
 --   fund.category,
  --invoice_line_item.line_price/100,
  ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) as line_price,
   TO_CHAR(i.invoice_update_date,'fmMM/ DD/ YYYY')  inv_update_date,
  '2016-2017' AS fiscal_period_name
--  TO_CHAR(invoice.invoice_status_date,'FMMM/DD/YYYY') AS paid_date,
 -- INVOICE_STATUS.INVOICE_STATUS_desc,
 -- l.ledger_name



           from ucladb.purchase_order po
inner join ucladb.vendor v on po.vendor_id = v.vendor_id
inner join ucladb.po_status pos on po.po_status = pos.po_status
INNER JOIN PO_TYPE pt ON po.PO_TYPE = pt.PO_TYPE
--INNER JOIN PO_TYPE ON PURCHASE_ORDER.PO_TYPE = PO_TYPE.PO_TYPE
inner join ucladb.line_item li on po.po_id = li.po_id
inner join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
inner join location l on lics.location_id = l.location_id
inner join ucladb.line_item_funds lif on lics.copy_id = lif.copy_id

--INNER JOIN LEDGER l ON lif.LEDGER_ID = l.LEDGER_ID

inner join ucladb.ucla_fundledger_vw f on lif.ledger_id = f.ledger_id and lif.fund_id = f.fund_id
INNER JOIN FUND_TYPE ft ON f.FUND_TYPE = ft.FUND_TYPE_name

inner join ucladb.bib_text bt on li.bib_id = bt.bib_id
inner join ucladb.invoice_line_item ili on li.line_item_id = ili.line_item_id
inner join ucladb.invoice i on ili.invoice_id = i.invoice_id
inner join ucladb.invoice_status ist on i.invoice_status = ist.invoice_status


WHERE ft.fund_type_name  LIKE 'Gift%'
     -- AND f.fund_category = '2'
      --AND f.fund_code = --'F3MPEANUB2'
        --                  'DONOTUSE2'
      AND  i.invoice_status_date BETWEEN to_date('20160701', 'YYYYMMDD') AND to_date('20170630', 'YYYYMMDD')
      AND ist.INVOICE_STATUS_desc = 'Approved'
     -- AND l.ledger_name LIKE '%14-15%'
    --  AND i.invoice_number = '781463'
    ORDER BY ft.fund_type_name, f.fund_name
