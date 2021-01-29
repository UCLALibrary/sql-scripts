SELECT distinct 
  --mi.item_enum,
  --mi.caption,
 -- pb.patron_barcode,
  ib.item_barcode,
  pa.address_line1 AS email_address,
  ista.item_status_desc 
 
FROM
  ucladb.item i
  INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
  INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE
  inner join item_barcode ib on i.item_id = ib.item_id
  INNER JOIN ucladb.circ_transactions cta ON i.item_id = cta.item_id
  INNER JOIN ucladb.patron p ON cta.patron_id = p.patron_id
 -- INNER JOIN PATRON_BARCODE pb ON p.PATRON_ID = pb.PATRON_ID
  left outer JOIN ucladb.patron_address pa ON p.patron_id = pa.patron_id
  left outer JOIN ADDRESS_TYPE aty ON pa.ADDRESS_TYPE = aty.ADDRESS_TYPE
  INNER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
 

WHERE aty.address_desc = 'EMail' and mi.caption = 'Chromebook' and ista.item_status_desc = 'Charged'

order by ib.item_barcode

