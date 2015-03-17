Enter file contents here
SELECT  DISTINCT
ucla_bibtext_vw.bib_id,
--ucla_bibtext_vw.isbn,
ucla_bibtext_vw.TITLE,
location.location_code

FROM ucla_bibtext_vw

INNER JOIN BIB_MFHD ON ucla_bibtext_vw.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN LOCATION
INNER JOIN MFHD_MASTER ON LOCATION.LOCATION_ID = MFHD_MASTER.LOCATION_ID ON BIB_MFHD.MFHD_ID = MFHD_MASTER.MFHD_ID


WHERE  location.location_code LIKE 'mg%'
--AND location.location_code LIKE 'sr%'
  -- AND item_vw.perm_location NOT LIKE 'SR%')
  AND ucla_bibtext_vw.bib_format = 'am'

  and exists (
        select *
        FROM bib_mfhd  bm2
        inner join mfhd_master on bm2.mfhd_id = mfhd_master.mfhd_id
        inner join location  on mfhd_master.location_id = location.location_id
        where bm2.bib_id = bib_mfhd.bib_id
        and location.location_code like 'sr%' )
