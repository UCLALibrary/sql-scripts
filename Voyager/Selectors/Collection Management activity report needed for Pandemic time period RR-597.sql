select --distinct  
  l.location_name
, Count (DISTINCT i.invoice_id) AS invoices
, Count(ili.line_item_id) AS inv_line_items
, Sum(ili.line_price/100) AS cost


from ucladb.purchase_order po
inner join ucladb.vendor v on po.vendor_id = v.vendor_id
inner join ucladb.po_status pos on po.po_status = pos.po_status
INNER JOIN PO_TYPE pot ON po.PO_TYPE = pot.PO_TYPE
inner join ucladb.line_item li on po.po_id = li.po_id
inner join ucladb.line_item_type lit on li.line_item_type = lit.line_item_type
inner join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
inner join location l on lics.location_id = l.location_id
inner join ucladb.bib_text bt on li.bib_id = bt.bib_id
INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
inner join ucladb.invoice_line_item ili on li.line_item_id = ili.line_item_id
inner join ucladb.invoice i on ili.invoice_id = i.invoice_id
INNER JOIN INVOICE_STATUS ista ON i.INVOICE_STATUS = ista.INVOICE_STATUS

 
where --bt.bib_format = 'am'
  --   (bt.bib_format = 'as' or bt.bib_format = 'ai')
     -- (bt.bib_format = 'cm' or bt.bib_format = 'cs')
   --   (bt.bib_format = 'gm' or bt.bib_format = 'gs' or bt.bib_format = 'km' or bt.bib_format = 'ks')
    --   (bt.bib_format = 'im' or bt.bib_format = 'is' or bt.bib_format = 'jm' or bt.bib_format = 'js')
        (bt.bib_format = 'mm' or bt.bib_format = 'ms')
  --  and pos.po_status_desc like 'Received%'
  --  and pos.po_status_desc = 'Approved/Sent'
    
  --  and li.update_date between to_date('20200301', 'YYYYMMDD') and to_date('20201002', 'YYYYMMDD') 
    and ista.invoice_status_desc = 'Approved'
    and ili.update_date between to_date('20200301', 'YYYYMMDD') and to_date('20210111', 'YYYYMMDD') 
    
    and l.location_code = 'in'
  --and l.location_code not like 'in%'
  

group by l.location_name
---------------------------------------------------------------------------------------
--SQL for PO's

select --distinct  
l.location_name
, Count (DISTINCT po.po_id) AS purchase_orders
, Count(li.line_item_id) AS line_items
, Sum(li.line_price/100) AS cost


from ucladb.purchase_order po
inner join ucladb.vendor v on po.vendor_id = v.vendor_id
inner join ucladb.po_status pos on po.po_status = pos.po_status
INNER JOIN PO_TYPE pot ON po.PO_TYPE = pot.PO_TYPE
inner join ucladb.line_item li on po.po_id = li.po_id
inner join ucladb.line_item_type lit on li.line_item_type = lit.line_item_type
inner join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
INNER JOIN LINE_ITEM_STATUS lis ON lics.LINE_ITEM_STATUS = lis.LINE_ITEM_STATUS

inner join location l on lics.location_id = l.location_id
inner join ucladb.bib_text bt on li.bib_id = bt.bib_id
INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
--inner join ucladb.invoice_line_item ili on li.line_item_id = ili.line_item_id
--inner join ucladb.invoice i on ili.invoice_id = i.invoice_id
--INNER JOIN INVOICE_STATUS ista ON i.INVOICE_STATUS = ista.INVOICE_STATUS

 
where --bt.bib_format = 'am'
  -- (bt.bib_format = 'as' or bt.bib_format = 'ai')
    --  (bt.bib_format = 'cm' or bt.bib_format = 'cs')
   --  (bt.bib_format = 'gm' or bt.bib_format = 'gs' or bt.bib_format = 'km' or bt.bib_format = 'ks')
     --  (bt.bib_format = 'im' or bt.bib_format = 'is' or bt.bib_format = 'jm' or bt.bib_format = 'js')
        (bt.bib_format = 'mm' or bt.bib_format = 'ms')
  --  and pos.po_status_desc like 'Received%'
  --  and pos.po_status_desc = 'Approved/Sent'
  --  and lis.line_item_status_desc like 'Received%'
     and lis.line_item_status_desc = 'Approved'
    
    and li.update_date between to_date('20200301', 'YYYYMMDD') and to_date('20210111', 'YYYYMMDD') 
  --  and ista.invoice_status_desc = 'Approved'
  --  and ili.update_date between to_date('20200301', 'YYYYMMDD') and to_date('20201002', 'YYYYMMDD') 
    
     and l.location_code = 'in'
 --  and l.location_code not like 'in%'
  

group by l.location_name



