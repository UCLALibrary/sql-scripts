SELECT  DISTINCT
bt.bib_id,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
bt.TITLE,
bt.author,
mm.display_call_no,
mm.normalized_call_no,
ib.item_barcode,
i.historical_charges,
(select max(charge_date_only) from circcharges_vw where mfhd_id = cc.mfhd_id) as latest_charge

    FROM ucla_bibtext_vw bt

INNER JOIN BIB_MFHD bm ON bt.BIB_ID = bm.BIB_ID
INNER JOIN MFHD_MASTER mm ON bm.MFHD_ID = mm.MFHD_ID
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON mm.MFHD_ID = mi.MFHD_ID
INNER JOIN ITEM i ON mi.ITEM_ID = i.ITEM_ID
INNER JOIN ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_ID

--INNER JOIN ITEM_STATS ist ON i.ITEM_ID = ist.ITEM_ID
--INNER JOIN ITEM_STAT_CODE istc ON ist.ITEM_STAT_ID = istc.ITEM_STAT_ID

left OUTER JOIN CIRCCHARGES_VW cc ON i.item_ID = cc.item_ID

    WHERE bt.series LIKE '%Advances in chemistry series%'
                         -- '%ACS symposium series%'

    -- AND NOT EXISTS (SELECT * FROM circcharges_vw WHERE mfhd_id = mm.mfhd_id)




    ORDER BY mm.normalized_call_no
