SELECT  DISTINCT


--ucla_bibtext_vw.bib_id,
--ucla_BIBTEXT_vw.bib_format,
ucla_BIBTEXT_vw.publisher,
ucla_BIBTEXT_vw.title,
--ucla_BIBTEXT_vw.author,
--ucla_BIBTEXT_vw.bib_id
--BIB_TEXT.author,
ucla_BIBTEXT_vw.imprint,
--ucla_BIBTEXT_vw.publisher,
--ucla_BIBTEXT_vw.publisher_date,
ucla_BIBTEXT_vw.LANGUAGE,
location.location_name,
MFHD_MASTER.display_call_no,
--ucladb.getmfhdtag(Mfhd_master.mfhd_id, '852') AS f852,
ucladb.getmfhdtag(Mfhd_master.mfhd_id, '866') AS f866





FROM ucla_BIBTEXT_vw
INNER JOIN BIB_MASTER ON ucla_BIBTEXT_vw.BIB_ID = BIB_MASTER.BIB_ID
INNER JOIN BIB_MFHD ON ucla_BIBTEXT_vw.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER ON BIB_MFHD.MFHD_ID = MFHD_MASTER.MFHD_ID
INNER JOIN LOCATION ON MFHD_MASTER.LOCATION_ID = LOCATION.LOCATION_ID


WHERE ucla_BIBTEXT_vw.title LIKE '%Fethullah%'
--Fethullah Gülen--  (ucla_BIBTEXT_vw.place_code = 'tu' OR ucla_BIBTEXT_vw.LANGUAGE = 'tur')  AND ucla_BIBTEXT_vw.bib_format = 'as'


    ORDER BY ucla_BIBTEXT_vw.publisher--title
