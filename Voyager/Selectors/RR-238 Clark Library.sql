SELECT  DISTINCT
location.location_code,
ucla_bibtext_vw.bib_id,
ucla_bibtext_vw.title,
ucla_bibtext_vw.author,
ucla_bibtext_vw.imprint,
mfhd_master.normalized_call_no


--ucladb.getbibsubfield(ucla_BIBTEXT_vw.bib_id, '260', 'c') as f260c,
--ucladb.getbibsubfield(ucla_BIBTEXT_vw.bib_id, '300', 'a') as f300a,
--ucladb.getbibsubfield(ucla_BIBTEXT_vw.bib_id, '501', 'a') as f501a,
--ucladb.getbibsubfield(ucla_BIBTEXT_vw.bib_id, '501', '5') as f5015,
--ucla_BIBTEXT_vw.BIB_ID,
--(SELECT REPLACE(normal_heading, 'UCOCLC', '')
  --    FROM bib_index WHERE bib_id = ucla_BIBTEXT_vw.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  --) AS oclc_number

FROM MFHD_MASTER
INNER JOIN MFHD_HISTORY ON MFHD_MASTER.MFHD_ID = MFHD_HISTORY.MFHD_ID
INNER JOIN LOCATION ON MFHD_MASTER.LOCATION_ID = LOCATION.LOCATION_ID
inner join bib_mfhd ON MFHD_MASTER.MFHD_ID = BIB_MFHD.MFHD_ID
INNER JOIN ucla_BIBTEXT_vw ON ucla_BIBTEXT_vw.BIB_ID = BIB_MFHD.BIB_ID

WHERE LOCATION.LOCATION_CODE like 'ck%'
      AND mfhd_master.normalized_call_no LIKE 'MS.%'


ORDER BY mfhd_master.normalized_call_no
