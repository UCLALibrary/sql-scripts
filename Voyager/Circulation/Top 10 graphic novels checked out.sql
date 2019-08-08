SELECT  DISTINCT
Count (*) AS CHARGES,
bt.author,
bt.TITLE,
mm.display_call_no,
bt.publisher,
bt.publisher_date,
l.location_code,
bt.bib_id
--ib.item_barcode,
--mm.mfhd_id



    FROM ucla_bibtext_vw bt

INNER JOIN BIB_MFHD bm ON bt.BIB_ID = bm.BIB_ID
INNER JOIN MFHD_MASTER mm ON bm.MFHD_ID = mm.MFHD_ID
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON mm.MFHD_ID = mi.MFHD_ID
INNER JOIN ITEM i ON mi.ITEM_ID = i.ITEM_ID
--INNER JOIN ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_ID



INNER JOIN CIRCCHARGES_VW cc ON i.item_ID = cc.item_ID

                    WHERE bt.bib_format = 'am'
                      AND
                      cc.charge_date_only between to_date('20140701', 'YYYYMMDD') AND to_date('20150630', 'YYYYMMDD')
                      AND l.location_code = 'clgrfn'
                      

                      --AND ROWNUM >= 25

    GROUP BY
    bt.author,
    bt.TITLE,
    mm.display_call_no,
    bt.publisher,
    bt.publisher_date,
    l.location_code,
    bt.bib_id

    ORDER BY charges DESC -
