SELECT  -- DISTINCT
Count (*) AS CHARGES,
--Max (cta.discharge_date) AS last_discharge_date,
--'' AS placeholder,
--l.location_code,
bt.bib_id,
bt.series,
bt.TITLE,
bt.author,
mm.display_call_no


FROM ucla_bibtext_vw bt

--bt
INNER JOIN BIB_MFHD ON bt.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER  mm
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID ON BIB_MFHD.MFHD_ID = mm.MFHD_ID
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
INNER JOIN ITEM i on mi.item_id = i.item_id

--INNER JOIN MFHD_ITEM ON i.ITEM_ID = MFHD_ITEM.ITEM_ID ON mm.MFHD_ID = MFHD_ITEM.MFHD_ID

left outer JOIN circ_trans_archive cta ON i.item_id = cta.item_id

--left outer join CIRCCHARGES_VW cc ON mm.MFHD_ID = cc.MFHD_ID

             where bt.series like 'Examples % explanations%'  --'Examples%'
                and 
                l.location_code = 'lwrs'--like 'lw%'
            AND cta.charge_date between to_date('20180701', 'YYYYMMDD') and to_date('20190630', 'YYYYMMDD')
            
            group by
            bt.bib_id,
            bt.series,
            l.location_code,
            bt.TITLE,
            bt.author,
            mm.display_call_no


ORDER BY  l.location_code,
mm.display_call_no
