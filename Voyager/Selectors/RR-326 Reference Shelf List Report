--First sort by normalized call number and not by location or any other field (such as whether it is oversize or not, the field without * in front) and then by enumeration
SELECT

bt.BIB_ID
, bt.network_number AS oclc_no
, l.LOCATION_CODE
--, bt.bib_format
, substr (bt.bib_format, 2  ) AS bib_level
, i.ITEM_ID
, ib.ITEM_BARCODE
, mm.MFHD_ID
, bt.TITLE
, bt.AUTHOR
, bt.PUBLISHER
, bt.PUB_PLACE
, bt.EDITION
, bt.BEGIN_PUB_DATE
, bt.LANGUAGE
, mm.NORMALIZED_CALL_NO
, mm.DISPLAY_CALL_NO
, mi.ITEM_ENUM


 FROM  ucladb.bib_text bt
  INNER JOIN ucladb.bib_item bi ON bt.bib_id = bi.bib_id
  INNER JOIN ucladb.item_status ist ON bi.item_id = ist.item_id
  INNER JOIN ucladb.item_status_type isty ON ist.item_status = isty.item_status_type
  INNER JOIN ucladb.item i ON bi.item_id = i.item_id
  INNER JOIN ucladb.item_barcode ib ON i.item_id = ib.item_id
  INNER JOIN ucladb.location l ON i.perm_location = l.location_id
  INNER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
  INNER JOIN ucladb.mfhd_master mm ON mi.mfhd_id = mm.mfhd_id


WHERE (l.location_code = 'yrrisrr'
    OR l.location_code = 'yrriscats'
    OR l.location_code = 'yrrisdsk'
    OR l.location_code = 'yrrisalce'
    OR l.location_code = 'yrrisalcw'
    OR l.location_code = 'yrrisatl'
    OR l.location_code = 'yrrisbio'
    OR l.location_code = 'yrrisedux'
    OR l.location_code = 'yrriselec'
    OR l.location_code = 'yrrisgrts'
    OR l.location_code = 'yrrismaps'
    OR l.location_code = 'yrrismi'
    OR l.location_code = 'yrrisnuc'
    OR l.location_code = 'yrristec'
    OR l.location_code = 'yrrisedu')

    ORDER BY mm.NORMALIZED_CALL_NO

