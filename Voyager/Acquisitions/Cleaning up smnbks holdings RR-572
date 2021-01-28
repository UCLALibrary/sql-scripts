select --distinct
  bmf.bib_id
, mm.mfhd_id
--, l.location_code
--, mm.normalized_call_no
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'h') AS f852h
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'i') AS f852i
--, mm.suppress_in_opac
--, ucladb.getmfhdtag(mm.mfhd_id, '852') AS f852
--, ucladb.getmfhdtag(mm.mfhd_id, '866') AS f866

FROM MFHD_MASTER mm

INNER JOIN BIB_MFHD bmf ON mm.MFHD_ID = bmf.MFHD_ID
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID

where l.location_code = 'smnbks'
