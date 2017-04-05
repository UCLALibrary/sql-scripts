/*	Approved/Sent POs with specific funds, where no invoice has been added since 7/1/2007
*/
SELECT DISTINCT
b.bib_id,
b.author,
--vger_subfields.Get880Field(b.bib_id, '100') as author_880,
b.title,
--vger_subfields.Get880Field(b.bib_id, '245') as title_880,
b.publisher_date,
mm.normalized_call_no AS call_number,

	f.fund_code
,	po.po_number
--, f.commitments
, li.line_price/100
, pos.po_status_desc
, l.ledger_name


FROM purchase_order po
INNER JOIN po_status pos ON po.po_status = pos.po_status
INNER JOIN line_item li ON po.po_id = li.po_id
INNER JOIN line_item_copy_status lics ON li.line_item_id = lics.line_item_id
INNER JOIN line_item_funds lif ON lics.copy_id = lif.copy_id
INNER JOIN fund f ON lif.ledger_id = f.ledger_id AND lif.fund_id = f.fund_id
INNER JOIN LEDGER l ON f.LEDGER_ID = l.LEDGER_ID
INNER JOIN ucla_bibtext_vw b ON li.bib_id = b.bib_id
INNER JOIN BIB_mfhd bmuf ON b.BIB_ID = bmuf.BIB_ID
INNER JOIN MFHD_MASTER mm ON bmuf.MFHD_ID = mm.MFHD_ID


WHERE --l.ledger_name like '%15-167' AND
        f.fund_name = 'Japanese CDL EMW'


ORDER BY f.fund_code, b.title
