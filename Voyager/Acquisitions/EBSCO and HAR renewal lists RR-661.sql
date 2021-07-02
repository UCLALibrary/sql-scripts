/*  Renewal lists for EBSCO & HAR, for selector review.
    RR-661, from SQL in Excel files done by Lola on RR-564 and RR-567
*/

-- HAR
SELECT distinct 
v.vendor_name
, pt.po_type_desc
, ps.po_status_desc
, vger_support.unifix(title) as title
--, bt.title
, bt.bib_id
, bt.issn
, po.po_number
, pon.note as po_note
, lin.note as li_note
, fv.fund_code
, fv.fund_name
, fv.ledger_name
, ( select
      i.invoice_number
    from invoice i
    inner join invoice_line_item ili on i.invoice_id = ili.invoice_id
    where ili.line_item_id = li.line_item_id
    and i.invoice_status_date = (select max(invoice_status_date) from invoice where invoice_id in (select invoice_id from invoice_line_item where line_item_id = ili.line_item_id))
     and rownum < 2 
) as latest_inv
FROM purchase_order po
INNER JOIN location l ON po.order_location = l.location_id
INNER JOIN po_type pt ON po.po_type = pt.po_type
INNER JOIN po_status ps ON po.po_status = ps.po_status
INNER JOIN line_item li ON po.po_id = li.po_id
INNER JOIN line_item_copy_status lics ON li.line_item_id = lics.line_item_id
INNER JOIN LINE_ITEM_FUNDS lif ON lics.COPY_ID = lif.COPY_ID
--INNER JOIN FUND f ON lif.FUND_ID = f.FUND_ID
--INNER JOIN LEDGER l ON lif.LEDGER_ID = l.LEDGER_ID
INNER JOIN ucla_FUNDLEDGER_VW fv ON lif.LEDGER_ID = fv.LEDGER_ID and lif.fund_id = fv.fund_id
inner join BIB_TEXT bt ON li.BIB_ID = bt.BIB_ID
INNER JOIN PO_NOTES pon ON li.PO_ID = pon.PO_ID
INNER JOIN LINE_ITEM_NOTES lin ON li.LINE_ITEM_ID = lin.LINE_ITEM_ID
--INNER JOIN PO_FUNDS pof ON po.PO_ID = pof.PO_ID 
--INNER JOIN FUNDLEDGER_VW fv ON pof.LEDGER_ID = fv.LEDGER_ID
--INNER JOIN FUND f ON pof.FUND_ID = f.FUND_ID
--INNER JOIN line_item_copy_status lics ON li.line_item_id = lics.line_item_id
inner join vendor v ON v.vendor_id = po.vendor_id
WHERE (pt.po_type_desc = 'Firm Order' or pt.po_type_desc = 'Approval' or pt.po_type_desc = 'Continuation')
      and v.vendor_code = 'HAR'
       --and po.po_number NOT LIKE 'DCS%'
       AND (ps.po_status_desc <> 'Received Complete' and ps.po_status_desc <> 'Canceled' and ps.po_status_desc <> 'Complete')
--AND li.create_DATE BETWEEN to_date('2012-07-01', 'YYYY-MM-DD') and to_date('2013-07-01', 'YYYY-MM-DD')
--AND (po.order_location = '550' OR po.order_location = '348' OR  po.order_location = '247')
order by vger_support.unifix(title)  --bt.title
;
-- 2623 rows 20210630; 2046, when re-done correctly


-- EBSCO
select distinct 
  v.vendor_name
, pt.po_type_desc
, ps.po_status_desc
, vger_support.unifix(title) as title
, bt.bib_id
, bt.issn
, po.po_number
, pon.note as po_note
, lin.note as li_note
, fv.fund_code
, fv.fund_name
, fv.ledger_name
, ( select
      i.invoice_number
    from invoice i
    inner join invoice_line_item ili on i.invoice_id = ili.invoice_id
    where ili.line_item_id = li.line_item_id
    and i.invoice_status_date = (select max(invoice_status_date) from invoice where invoice_id in (select invoice_id from invoice_line_item where line_item_id = ili.line_item_id))
     and rownum < 2 
) as latest_inv
from purchase_order po
INNER JOIN location l ON po.order_location = l.location_id
INNER JOIN po_type pt ON po.po_type = pt.po_type
INNER JOIN po_status ps ON po.po_status = ps.po_status
INNER JOIN line_item li ON po.po_id = li.po_id
INNER JOIN line_item_copy_status lics ON li.line_item_id = lics.line_item_id
INNER JOIN LINE_ITEM_FUNDS lif ON lics.COPY_ID = lif.COPY_ID
--INNER JOIN FUND f ON lif.FUND_ID = f.FUND_ID
--INNER JOIN LEDGER l ON lif.LEDGER_ID = l.LEDGER_ID
INNER JOIN ucla_FUNDLEDGER_VW fv ON lif.LEDGER_ID = fv.LEDGER_ID and lif.fund_id = fv.fund_id
--INNER JOIN INVOICE_LINE_ITEM ili ON li.LINE_ITEM_ID = ili.LINE_ITEM_ID
inner join BIB_TEXT bt ON li.BIB_ID = bt.BIB_ID
INNER JOIN PO_NOTES pon ON li.PO_ID = pon.PO_ID
INNER JOIN LINE_ITEM_NOTES lin ON li.LINE_ITEM_ID = lin.LINE_ITEM_ID
inner join vendor v ON v.vendor_id = po.vendor_id
--where po.po_number = 'ART-103494'
WHERE (pt.po_type_desc = 'Firm Order' or pt.po_type_desc = 'Approval' or pt.po_type_desc = 'Continuation')
     and v.vendor_code in ('EBS', 'EBSCOFR', 'EPJ', 'BEB')
     --and po.po_number NOT LIKE 'DCS%'
     AND (ps.po_status_desc <> 'Received Complete' and ps.po_status_desc <> 'Canceled' and ps.po_status_desc <> 'Complete')
;
-- 1726 rows 20210630; 1192 when redone correctly
