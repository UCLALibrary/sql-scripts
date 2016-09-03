/*	Approved/Sent POs with specific funds, where no invoice has been added since 7/1/2007
*/
SELECT DISTINCT
  ucladb.getbibtag(bt.Bib_id, '001') AS f001
, ucladb.getbibsubfield(bt.bib_id, '002', 'a') AS F002a
,	bt.title
,	bt.imprint
, ucladb.getbibsubfield(bt.bib_id, '362', 'a') AS f362a
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'b') AS f852b
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'h') AS f852h
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'z') AS f852z
, ucladb.getmfhdsubfield(mm.mfhd_id, '856', 'u') AS f852u
, ucladb.getmfhdsubfield(mm.mfhd_id, '856', 'x') AS f852x
, ucladb.getmfhdsubfield(mm.mfhd_id, '866', 'a') AS f866a
, v.vendor_code
,	f.fund_code
, lin.note

,	po.po_number
--, f.commitments
--, li.line_price/100
--, pos.po_status_desc
--, l.ledger_name


FROM purchase_order po
INNER JOIN po_status pos ON po.po_status = pos.po_status
INNER JOIN PO_TYPE pot ON po.PO_TYPE = pot.PO_TYPE
inner join ucladb.vendor v on po.vendor_id = v.vendor_id

INNER JOIN line_item li ON po.po_id = li.po_id
INNER JOIN line_item_copy_status lics ON li.line_item_id = lics.line_item_id
INNER JOIN line_item_funds lif ON lics.copy_id = lif.copy_id
INNER JOIN line_item_notes lin ON li.line_item_id = lin.line_item_id

INNER JOIN fund f ON lif.ledger_id = f.ledger_id AND lif.fund_id = f.fund_id
INNER JOIN LEDGER l ON f.LEDGER_ID = l.LEDGER_ID
INNER JOIN ucla_bibtext_vw bt ON li.bib_id = bt.bib_id
INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
--INNER JOIN LOCATION ON MFHD_MASTER.LOCATION_ID = LOCATION.LOCATION_ID




WHERE  pot.po_type_desc = 'Continuation'
AND l.ledger_name = 'CRIS 16-17'


ORDER BY f.fund_code, bt.title

