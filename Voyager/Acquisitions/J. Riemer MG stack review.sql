SELECT
Count (*) AS CHARGES,
 bt.bib_id,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
mm.normalized_call_no,
mm.display_call_no,
ucladb.getmfhdsubfield(mm.mfhd_id, '866', 'a') AS f866a,
ucladb.getmfhdsubfield(mm.mfhd_id, '867', 'a') AS f867a,
ucladb.getmfhdsubfield(mm.mfhd_id, '868', 'a') AS f868a,

bt.TITLE,
bt.author,
bt.pub_place,
bt.publisher,
bt.begin_pub_date AS date_1,
bt.end_pub_date AS date_2,
 Count (DISTINCT item.item_id) AS items


FROM ucla_bibtext_vw bt

--bt
INNER JOIN BIB_MFHD ON bt.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER  mm
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID ON BIB_MFHD.MFHD_ID = mm.MFHD_ID
INNER JOIN ITEM
INNER JOIN MFHD_ITEM ON ITEM.ITEM_ID = MFHD_ITEM.ITEM_ID ON mm.MFHD_ID = MFHD_ITEM.MFHD_ID

INNER JOIN CIRCCHARGES_VW cc ON mm.MFHD_ID = cc.MFHD_ID

            WHERE l.location_code = 'mg'
-- Either (1) or (2) must be true:
-- (1) No other holdings, or (2) only other Voyager holdings are suppressed or are Internet
AND     (
        NOT EXISTS
                -- (1) No other holdings
                (       SELECT *
                        from bib_mfhd bm2
                        inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
                        inner join location l2 on mm2.location_id = l2.location_id
                        where bm2.bib_id = bt.bib_id
                        and mm2.mfhd_id != mm.mfhd_id -- DIFFERENT MFHD
                )
         OR NOT EXISTS
                -- (2) Other mfhds are either suppressed or Internet
                (       select *
                        from bib_mfhd bm3
                        inner join mfhd_master mm3 on bm3.mfhd_id = mm3.mfhd_id
                        inner join location l3 on mm3.location_id = l3.location_id
                        where bm3.bib_id = bt.bib_id
                        and mm3.mfhd_id != mm.mfhd_id -- DIFFERENT MFHD
                        AND (mm3.suppress_in_opac = 'N' OR l3.location_code != 'in')
                )

            )

            AND (bt.bib_format = 'am' OR bt.bib_format = 'ai')
            AND cc.charge_date_only > '31/DEC/2003'

group BY
