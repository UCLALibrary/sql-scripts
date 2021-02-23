SELECT DISTINCT
vger_support.unifix(title) as title,
vger_subfields.Get880Field(bib_text.bib_id, '245') as title_880,
vger_support.unifix(author) as author,
vger_subfields.Get880Field(bib_text.bib_id, '100') as author_880,
Mfhd_Master.normalized_call_no AS call_number,
BIB_TEXT.bib_id,
vger_support.unifix(publisher) AS publisher,
vger_support.unifix(publisher_date) as publisher_date,
vger_support.unifix(series) AS series,
vger_report.cat_948_base_rpt.S948C AS cataloging_date,
ucladb.getbibsubfield(bib_text.bib_id, '901', 'b') as f901b

FROM vger_report.cat_948_base_rpt

INNER JOIN BIB_TEXT ON vger_report.cat_948_base_rpt.bib_id = bib_text.bib_id
INNER JOIN BIB_MFHD ON BIB_TEXT.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN BIB_MASTER ON BIB_TEXT.BIB_ID = BIB_MASTER.BIB_ID
INNER JOIN MFHD_MASTER ON MFHD_MASTER.MFHD_ID = BIB_MFHD.MFHD_ID
inner join location on mfhd_master.location_id = location.location_id


WHERE LOCATION.LOCATION_CODE like 'ea%'
      AND LOCATION.LOCATION_CODE <> 'eaacq'
      AND BIB_TEXT.LANGUAGE= 'jpn'
      AND Mfhd_Master.SUPPRESS_IN_OPAC <> 'Y'
      AND s948c between to_char(trunc(sysdate-30), 'YYYYMMDD') and to_char(trunc(sysdate), 'YYYYMMDD')

ORDER BY  Mfhd_Master.normalized_call_no
