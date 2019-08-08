
SELECT DISTINCT
--ucla_fundledger_vw.ledger_name
  ucladb.getbibtag(ucla_BIBTEXT_vw.Bib_id, '001') AS f001
, ucladb.getbibsubfield(ucla_BIBTEXT_vw.bib_id, '002', 'a') AS F002a
, ucla_BIBTEXT_vw.TITLE
, ucla_BIBTEXT_vw.imprint
, ucladb.getbibsubfield(ucla_BIBTEXT_vw.bib_id, '362', 'a') AS f362a
, ucladb.getmfhdsubfield(mfhd_master.mfhd_id, '852', 'b') AS f852b
, ucladb.getmfhdsubfield(mfhd_master.mfhd_id, '852', 'h') AS f852h
, ucladb.getmfhdsubfield(mfhd_master.mfhd_id, '852', 'z') AS f852z
, ucladb.getmfhdsubfield(mfhd_master.mfhd_id, '856', 'u') AS f852u
, ucladb.getmfhdsubfield(mfhd_master.mfhd_id, '856', 'x') AS f852x
, ucladb.getmfhdsubfield(mfhd_master.mfhd_id, '866', 'a') AS f866a
, vendor.vendor_code
, ucla_fundledger_vw.fund_code
, LINE_ITEM_NOTES.note
, purchase_order.po_number
, invoice_line_item.line_price
, LINE_ITEM_STATUS.line_item_status_desc
, purchase_order.adjustments_subtotal
, line_item_type.line_item_type_desc
, purchase_order.currency_code
, ucla_fundledger_vw.ledger_name
, ucla_fundledger_vw.commitments
, line_item.line_price
, po_status.po_status_desc

FROM ucla_fundledger_vw
INNER JOIN LINE_ITEM_FUNDS ON ucla_fundledger_vw.FUND_ID = LINE_ITEM_FUNDS.FUND_ID AND
ucla_fundledger_vw.LEDGER_ID = LINE_ITEM_FUNDS.LEDGER_ID
INNER JOIN ucla_BIBTEXT_vw
INNER JOIN PO_STATUS
INNER JOIN PO_TYPE
INNER JOIN PURCHASE_ORDER ON PO_TYPE.PO_TYPE = PURCHASE_ORDER.PO_TYPE ON PO_STATUS.PO_STATUS = PURCHASE_ORDER.PO_STATUS
INNER JOIN LINE_ITEM ON PURCHASE_ORDER.PO_ID = LINE_ITEM.PO_ID ON ucla_BIBTEXT_vw.BIB_ID = LINE_ITEM.BIB_ID
INNER JOIN LINE_ITEM_TYPE ON LINE_ITEM.LINE_ITEM_TYPE = LINE_ITEM_TYPE.LINE_ITEM_TYPE
left OUTER JOIN LINE_ITEM_NOTES ON LINE_ITEM.LINE_ITEM_ID = LINE_ITEM_NOTES.LINE_ITEM_ID
INNER JOIN LINE_ITEM_COPY_STATUS ON LINE_ITEM.LINE_ITEM_ID = LINE_ITEM_COPY_STATUS.LINE_ITEM_ID ON LINE_ITEM_FUNDS.COPY_ID = LINE_ITEM_COPY_STATUS.COPY_ID
INNER JOIN LINE_ITEM_STATUS ON LINE_ITEM_COPY_STATUS.LINE_ITEM_STATUS = LINE_ITEM_STATUS.LINE_ITEM_STATUS
INNER JOIN VENDOR ON PURCHASE_ORDER.VENDOR_ID = VENDOR.VENDOR_ID
INNER JOIN LOCATION ON LINE_ITEM_COPY_STATUS.LOCATION_ID = LOCATION.LOCATION_ID AND
LINE_ITEM_COPY_STATUS.LOCATION_ID = LOCATION.LOCATION_ID
left outer JOIN INVOICE_LINE_ITEM ON LINE_ITEM.LINE_ITEM_ID = INVOICE_LINE_ITEM.LINE_ITEM_ID AND LINE_ITEM.LINE_ITEM_ID = INVOICE_LINE_ITEM.LINE_ITEM_ID
left outer JOIN INVOICE ON INVOICE_LINE_ITEM.INVOICE_ID = INVOICE.INVOICE_ID
INNER JOIN MFHD_MASTER ON LOCATION.LOCATION_ID = MFHD_MASTER.LOCATION_ID AND LINE_ITEM_COPY_STATUS.MFHD_ID = MFHD_MASTER.MFHD_ID


WHERE  po_type.po_type_desc = 'Continuation'
AND ucla_fundledger_vw.ledger_name LIKE 'SSH%'
AND invoice.invoice_update_date >= to_date('20160701', 'YYYYMMDD')

ORDER BY  ucla_fundledger_vw.fund_code, ucla_BIBTEXT_vw.TITLE

