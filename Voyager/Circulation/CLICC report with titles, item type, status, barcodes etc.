SELECT DISTINCT
bt.bib_id,
bt.title,
it.item_type_name,
ib.item_barcode,
ista.item_status_desc,
mi.ITEM_ENUM,
mi.year,
l.location_name, 
i.create_date,
i.modify_date

FROM ucla_BIBTEXT_vw bt

INNER join BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER join MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
inner join LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
inner join MFHD_ITEM mi ON mm.MFHD_ID = mi.MFHD_ID
inner join ITEM i ON mi.ITEM_ID = i.ITEM_ID
inner join ITEM_TYPE it ON i.ITEM_TYPE_ID = it.ITEM_TYPE_ID
inner join ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE

left outer join CIRC_TRANS_archive ct ON i.ITEM_ID = ct.ITEM_ID


WHERE     bt.title like 'CLICC%'  

  order by bt.title
