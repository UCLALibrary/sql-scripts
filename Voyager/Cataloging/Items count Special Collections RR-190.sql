SELECT  -- DISTINCT  
--location.location_name,
ucla_bibtext_vw.bib_id,
ucla_bibtext_vw.author,
ucla_bibtext_vw.title,
--Count (DISTINCT ucla_bibtext_vw.bib_id) AS title_count,
Count (ITEM_VW.item_id) AS item_count

FROM ucla_bibtext_vw
INNER JOIN BIB_MFHD ON ucla_bibtext_vw.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER ON BIB_MFHD.MFHD_ID = MFHD_MASTER.MFHD_ID
INNER JOIN LOCATION ON MFHD_MASTER.LOCATION_ID = LOCATION.LOCATION_ID
INNER JOIN ITEM_VW ON MFHD_MASTER.MFHD_ID = ITEM_VW.MFHD_ID
--INNER JOIN ITEM_BARCODE ON ITEM_VW.ITEM_ID = ITEM_BARCODE.ITEM_ID
--INNER JOIN ITEM_STATUS ON ITEM_BARCODE.ITEM_ID = ITEM_STATUS.ITEM_ID
--INNER JOIN ITEM_STATUS_TYPE ON ITEM_STATUS.ITEM_STATUS = ITEM_STATUS_TYPE.ITEM_STATUS_TYPE
                                  --
WHERE location.location_display_name LIKE '%Special%'


    GROUP BY --location.location_name,
              ucla_bibtext_vw.bib_id,
              ucla_bibtext_vw.author,
              ucla_bibtext_vw.title

              ORDER BY ucla_bibtext_vw.title
