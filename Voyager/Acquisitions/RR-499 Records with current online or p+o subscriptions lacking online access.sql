select distinct
  bt.bib_id
, vger_support.unifix(bt.title) as title
-- included for testing only
--, ucladb.getbibsubfield(bt.bib_id, '856', 'x') as f856x

from bib_text bt
INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN mfhd_master mm ON bmf.mfhd_id = mm.mfhd_id
INNER JOIN location l ON mm.location_id = l.location_id
inner join line_item li on bt.bib_id = li.bib_id
INNER JOIN INVOICE_LINE_ITEM ili ON li.LINE_ITEM_ID = ili.LINE_ITEM_ID
inner join purchase_order po on li.po_id = po.po_id
inner join po_type pot on po.po_type = pot.po_type
INNER JOIN PO_STATUS pos ON po.PO_STATUS = pos.PO_STATUS

where bib_format in ('ai', 'as')
      and mm.suppress_in_opac = 'N' 
      and l.location_code = 'in'
      and pot.po_type_desc = 'Continuation'
      and pos.po_status_desc in ('Approved/Sent', 'Received Partial')
      
and not exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bt.bib_id
  and tag = '856x'
  and subfield in ('UCLA', 'UCLA Law')
  
)

            UNION ALL

SELECT distinct
bt.bib_id,
bt.title

FROM ucla_bibtext_vw bt
INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN mfhd_master mm ON bmf.mfhd_id = mm.mfhd_id
INNER JOIN location l ON mm.location_id = l.location_id
inner join line_item li on bt.bib_id = li.bib_id
INNER JOIN INVOICE_LINE_ITEM ili ON li.LINE_ITEM_ID = ili.LINE_ITEM_ID
inner join purchase_order po on li.po_id = po.po_id
inner join po_type pot on po.po_type = pot.po_type
INNER JOIN PO_STATUS pos ON po.PO_STATUS = pos.PO_STATUS


WHERE  bib_format in ('ai', 'as')
      and mm.suppress_in_opac = 'N' 
      and pot.po_type_desc = 'Continuation'
      and pos.po_status_desc in ('Approved/Sent', 'Received Partial')      
      and ili.piece_identifier like '%p+o%'
      
      and not exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bt.bib_id
  and tag = '856x'
  and subfield in ('UCLA', 'UCLA Law')
  
)

--order by bt.title




