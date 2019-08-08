
SELECT  -- DISTINCT
bt.bib_id,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
iv.barcode,
bt.TITLE,
mm.display_call_no,
l.location_code,
iv.enumeration,
--iv.chronology,
--iv.year,
bt.pub_dates_combined,
ucladb.getbibtag(bt.Bib_id, '650') AS subject,
bt.pub_place

, case
    when exists (
        select *
        from bib_mfhd bm4
        inner join mfhd_master mm4 on bm4.mfhd_id = mm4.mfhd_id
        inner join location l4 on mm4.location_id = l4.location_id
        where bm4.bib_id = bt.bib_id
        and l4.location_code like 'sr%' --or like 'sr%', depending on your requirements
      ) then 'Y'
                else 'N'
end as has_srlf

FROM ucla_bibtext_vw bt

--bt
INNER JOIN BIB_MFHD ON bt.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER  mm
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID ON BIB_MFHD.MFHD_ID = mm.MFHD_ID
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
INNER JOIN ITEM_vw iv on mi.item_id = iv.item_id

--INNER JOIN MFHD_ITEM ON i.ITEM_ID = MFHD_ITEM.ITEM_ID ON mm.MFHD_ID = MFHD_ITEM.MFHD_ID
--left outer JOIN circ_trans_archive cta ON i.item_id = cta.item_id
--left outer join CIRCCHARGES_VW cc ON mm.MFHD_ID = cc.MFHD_ID

             where l.location_code in ('yralmi', 'yrmi', 'yrmiclsd', 'yrmiguides', 'yrmisr', 'yrnbks') --like 'lw%'
         --   AND cta.charge_date between to_date('20180701', 'YYYYMMDD') and to_date('20190630', 'YYYYMMDD')
            
           

ORDER BY  l.location_code,
mm.display_call_no
