select distinct 
  po.po_number
, f.ledger_name  
, vger_support.unifix(title) as title
, v.vendor_name
, v.vendor_code
, f.fund_code
, f.fund_name
, ( select
      i.invoice_number
    from invoice i
    inner join invoice_line_item ili on i.invoice_id = ili.invoice_id
    where ili.line_item_id = li.line_item_id
    and i.invoice_status_date = (select max(invoice_status_date) from invoice where invoice_id in (select invoice_id from invoice_line_item where line_item_id = ili.line_item_id))
     and rownum < 2 
) as latest_inv

, ( select
      i.invoice_date
    from invoice i
    inner join invoice_line_item ili on i.invoice_id = ili.invoice_id
    where ili.line_item_id = li.line_item_id
    and i.invoice_status_date = (select max(invoice_status_date) from invoice where invoice_id in (select invoice_id from invoice_line_item where line_item_id = ili.line_item_id))
     and rownum < 2 
) as latest_inv_date

, (select
    ili.piece_identifier
    from invoice_line_item ili
    --inner join line_item li on ili.line_item_id = li.line_item_id
    inner join invoice i on ili.invoice_id = i.invoice_id
    where ili.line_item_id = li.line_item_id
    and i.invoice_status_date = (select max(invoice_status_date) from invoice where invoice_id in (select invoice_id from invoice_line_item where line_item_id = ili.line_item_id))
     and rownum < 2 
) as latest_piece_id

--, l.location_name
, bt.bib_id
--, mm.mfhd_id
 
from purchase_order po
INNER JOIN po_type pt ON po.po_type = pt.po_type
INNER JOIN PO_STATUS pos ON po.PO_STATUS = pos.PO_STATUS
INNER JOIN line_item li ON po.po_id = li.po_id
INNER JOIN line_item_copy_status lics ON li.line_item_id = lics.line_item_id

INNER JOIN LINE_ITEM_FUNDS lif ON lics.COPY_ID = lif.COPY_ID
INNER JOIN ucla_fundledger_vw f ON lif.FUND_ID = f.FUND_ID
inner join BIB_TEXT bt ON li.BIB_ID = bt.BIB_ID
INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
inner join location l on mm.location_id = l.location_id
inner join vendor v ON v.vendor_id = po.vendor_id

 
WHERE pt.po_type_desc = 'Continuation'
      and (pos.po_status_desc = 'Approved/Sent' or pos.po_status_desc = 'Received Partial')
      and (f.ledger_name like '%20-21%'
      and f.ledger_name not like 'EAST ASIAN%'
      and f.ledger_name not like 'LAW DIFFERENTIAL%'
      and f.ledger_name not like 'MUSIC%'
      and f.ledger_name not like 'SPECIAL COLLECTIONS%')
      and (po.po_number NOT LIKE 'DCS%'
      and po.po_number NOT LIKE 'EAL%'
      and po.po_number NOT LIKE 'MUS%'
      and po.po_number NOT LIKE 'LAW%')
      and l.location_name not like '%Internet%'
  
      and l.location_code not like 'sr%'
      
    --  and latest_inv <> ''
  
            
     
      order by --latest_inv
      vger_support.unifix(title)
   


      
      
   

