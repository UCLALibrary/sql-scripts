select  
--i.invoice_status_date as purchase_date
  f.fund_code
, To_Char (i.invoice_status_date,'fmMM/DD/YYYY') AS purchase_date
, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) as purchase_price
, v.vendor_name as dealer
, bt.author
, bt.title
, bt.imprint
, ucladb.getbibsubfield(bt.bib_id, '510', 'c') as aldine_cat_no
, bt.bib_id as record_number
, mm.display_call_no   



from ucladb.purchase_order po
inner join ucladb.vendor v on po.vendor_id = v.vendor_id
inner join ucladb.po_status pos on po.po_status = pos.po_status
inner join ucladb.line_item li on po.po_id = li.po_id
inner join ucladb.line_item_type lit on li.line_item_type = lit.line_item_type
inner join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
inner join location l on lics.location_id = l.location_id
inner join ucladb.line_item_funds lif on lics.copy_id = lif.copy_id
inner join ucladb.fund f on lif.ledger_id = f.ledger_id and lif.fund_id = f.fund_id
--inner join UCLADB.fundledger_vw flw on lif.ledger_id = flw.ledger_id
inner join ucladb.bib_text bt on li.bib_id = bt.bib_id
INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
left outer join ucladb.invoice_line_item ili on li.line_item_id = ili.line_item_id
left outer join ucladb.invoice i on ili.invoice_id = i.invoice_id
left outer join ucladb.invoice_status ist on i.invoice_status = ist.invoice_status

where ucladb.getbibsubfield(bt.bib_id, '901', 'b') = 'Ahmanson-Murphy Aldine Collection'
and (f.fund_code = 'F3MPSCALD2' or f.fund_code = 'F3MPSCFDM2') 

 and i.invoice_status_date between to_date('20120101', 'YYYYMMDD') and to_date('20190630', 'YYYYMMDD') 


order by --mm.normalized_call_no, 
      i.invoice_status_date

