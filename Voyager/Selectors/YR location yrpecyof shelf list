SELECT
  bt.bib_id
, bt.title
, bt.author
, bt.imprint
, bt.begin_pub_date
, mm.normalized_call_no
, ucladb.getallmfhdtag(mm.mfhd_id, '852') AS f852
--, ucladb.getallmfhdtag(mm.mfhd_id, '856') AS f856

, ucladb.getallmfhdtag(mm.mfhd_id, '866') AS f866



FROM BIB_TEXT  bt
INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID

WHERE l.location_code = 'yrpecyof'

ORDER BY mm.normalized_call_no


