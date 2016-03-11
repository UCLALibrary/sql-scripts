SELECT  DISTINCT
ucla_bibtext_vw.bib_id,
ucla_bibtext_vw.title,
ucla_bibtext_vw.issn,
ucladb.getbibsubfield(ucla_bibtext_vw.bib_id, '310', 'a') as f310a,
substr(ucla_bibtext_vw.field_008, 19, 1) AS bib_008_18,
substr(ucla_bibtext_vw.field_008, 23, 1) AS bib_008_22,
location.location_code,
SubStr(MFHD_MASTER.field_008, 7, 1) AS holdings_008_06,
SubStr(MFHD_MASTER.field_008, 8, 1) AS holdings_008_07,
SubStr(MFHD_MASTER.field_008, 9, 4) AS holdings_008_08_11,
SubStr(MFHD_MASTER.field_008, 13, 1) AS holdings_008_12,
ucladb.getmfhdsubfield(Mfhd_master.mfhd_id, '866', 'a') AS f866a
--mfhd_master.field_008

FROM ucla_bibtext_vw
INNER JOIN BIB_MFHD ON ucla_bibtext_vw.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER  ON bib_mfhd.mfhd_id = mfhd_master.mfhd_id
INNER JOIN LOCATION ON MFHD_MASTER.LOCATION_ID = LOCATION.LOCATION_ID


WHERE  ucla_bibtext_vw.bib_format = 'as'
       AND substr(ucla_bibtext_vw.field_008, 22, 1) = 'n'
       AND ucla_bibtext_vw.date_type_status = 'c'
      -- substr(ucla_bibtext_vw.field_008, 07, 1) = 'c'
       AND location.location_code LIKE '%yr%'

ORDER BY ucla_bibtext_vw.title
