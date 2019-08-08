SELECT DISTINCT
mfhd_master.normalized_call_no,
bib_text.bib_id,
Bib_Text.TITLE,
--Bib_Text.AUTHOR,
Bib_Text.PUBLISHER,
ucladb.getmfhdtag(Mfhd_master.mfhd_id, '866') AS f866
--Bib_Text.PUBLISHER_DATE,
--Bib_Text.SERIES,
--location.location_name

FROM LOCATION
INNER JOIN Mfhd_Master ON LOCATION.LOCATION_ID = Mfhd_Master.LOCATION_ID
INNER JOIN Bib_Text
INNER JOIN BIB_MFHD ON Bib_Text.BIB_ID = BIB_MFHD.BIB_ID ON Mfhd_Master.MFHD_ID = BIB_MFHD.MFHD_ID
--INNER JOIN PURCHASE_ORDER INNER JOIN LINE_ITEM ON PURCHASE_ORDER.PO_ID = LINE_ITEM.PO_ID ON BIB_MFHD.BIB_ID = LINE_ITEM.BIB_ID
--INNER JOIN INVOICE_LINE_ITEM ON LINE_ITEM.LINE_ITEM_ID = INVOICE_LINE_ITEM.LINE_ITEM_ID

WHERE
location.location_display_name ='Powell Library Main Reading Room Reference'



--AND Mfhd_Master.SUPPRESS_IN_OPAC <> 'Y'

ORDER BY Bib_Text.title
