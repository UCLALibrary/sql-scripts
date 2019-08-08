SELECT   DISTINCT
Count (*) AS CHARGES,
--'' AS placeholder,
mm.display_call_no,
TO_CHAR (i.create_date,'FMMM/DD/YYYY') AS date_of_acq,
bt.author,
bt.TITLE,
ucladb.getbibtag(bt.Bib_id, '650') AS f650

FROM ucla_bibtext_vw bt

--bt
INNER JOIN BIB_MFHD ON bt.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER  mm
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID ON BIB_MFHD.MFHD_ID = mm.MFHD_ID
INNER JOIN ITEM i
INNER JOIN MFHD_ITEM ON i.ITEM_ID = MFHD_ITEM.ITEM_ID ON mm.MFHD_ID = MFHD_ITEM.MFHD_ID

INNER JOIN CIRCCHARGES_VW cc ON mm.MFHD_ID = cc.MFHD_ID

            WHERE l.location_code = 'cl'
          --  AND cc.charge_date_only >= to_date('20120501', 'YYYYMMDD')

group BY
mm.display_call_no,
i.create_date,
bt.author,
bt.TITLE,
ucladb.getbibtag(bt.Bib_id, '650')


ORDER BY  mm.display_call_no
