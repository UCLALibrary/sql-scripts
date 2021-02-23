SELECT --DISTINCT
ucla_bibtext_vw.bib_id,
mfhd_master.display_call_no,
ucladb.getbibtag(ucla_bibtext_vw.Bib_id, '650') AS subject_heading,
ucladb.getbibtag(ucla_bibtext_vw.Bib_id, '500') AS notes,
ucladb.getbibtag(ucla_bibtext_vw.Bib_id, '501') AS with_note,--table_of_contents,
vger_subfields.Get880Field(ucla_bibtext_vw.bib_id, '245') as title_880,
ucla_bibtext_vw.TITLE,
ucla_bibtext_vw.PUB_place,
location.location_name,
ucla_bibtext_vw.begin_pub_date

FROM ucla_bibtext_vw
INNER JOIN BIB_MFHD ON ucla_BIBTEXT_vw.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER ON BIB_MFHD.MFHD_ID = MFHD_MASTER.MFHD_ID
inner join location on mfhd_master.location_id = location.location_id

WHERE     ucla_bibtext_vw.LANGUAGE = 'chi'
          AND ucla_bibtext_vw.begin_pub_date BETWEEN '1911' AND '1950'

 ORDER BY ucla_bibtext_vw.BEGIN_pub_date

