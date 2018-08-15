
SELECT DISTINCT
ucla_bibtext_vw.bib_id,
vger_support.unifix(title) as title,
vger_subfields.Get880Field(ucla_bibtext_vw.bib_id, '245') as title_880,
vger_support.unifix(author) as author,
vger_subfields.Get880Field(ucla_bibtext_vw.bib_id, '100') as author_880,
ucladb.getbibtag(ucla_bibtext_vw.Bib_id, '700') AS personal_name,
vger_subfields.Get880Field(ucla_bibtext_vw.bib_id, '700') as personal_name_880,
ucla_bibtext_vw.network_number AS oclc,
ucla_bibtext_vw.isbn,
mfhd_master.normalized_call_no,
ucla_bibtext_vw.publisher

FROM ucla_bibtext_vw
INNER JOIN BIB_MFHD ON ucla_BIBTEXT_vw.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER ON BIB_MFHD.MFHD_ID = MFHD_MASTER.MFHD_ID

inner join vger_subfields.ucladb_bib_subfield bs on bib_mfhd.bib_id = bs.record_id and bs.tag = '901b'

where bs.subfield LIKE 'Collection on Shanghai and Shanghai Studies'
 
--LIKE 'Chinese Grassroots Gazetteer and History Collection'


--LIKE '%Chinese New Genealogy Collection%'

--like 'Zhi Qing Collection - China%s Campaign Sending Urban Intellectual Youth%'

order by title
