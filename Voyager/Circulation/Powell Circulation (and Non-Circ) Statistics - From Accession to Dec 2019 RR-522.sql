--USE THIS IT IS THE GOOD ONE!!

SELECT DISTINCT
Count (cta.charge_date) AS charges,
mm.normalized_call_no,
bt.bib_id,
iv.item_id,
bt.isbn,
bt.author,
bt.title,
iv.enumeration,
bt.publisher,
l.LOCATION_CODE,
l.LOCATION_NAME,
bt.PUB_DATES_COMBINED,
TO_CHAR(iv.create_date,'YYYY-MM-DD') AS acc_date,
Max (TO_CHAR(cta.discharge_date, 'YYYY-MM-DD')) AS last_discharge

    , case
    when exists (
        select *
        from bib_mfhd bm2
        inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
        inner join location l2 on mm2.location_id = l2.location_id
        where bm2.bib_id = bt.bib_id
        and l2.location_code = 'sr' --or like 'sr%', depending on your requirements
      ) then 'Y'
                else 'N'
end as has_srlf

, case
    when exists (
        select *
        from bib_mfhd bm3
        inner join mfhd_master mm3 on bm3.mfhd_id = mm3.mfhd_id
        inner join location l3 on mm3.location_id = l3.location_id
        where bm3.bib_id = bt.bib_id
        and l3.location_code not in ('cl', 'sr')
      ) then 'Y'
                else 'N'
end as has_other

FROM
ITEM_vw iv
INNER JOIN circ_trans_archive cta ON iv.ITEM_ID = cta.ITEM_ID
INNER JOIN BIB_ITEM bi ON iv.ITEM_ID = bi.ITEM_ID
INNER JOIN ucla_bibtext_vw bt ON bi.BIB_ID = bt.BIB_ID
INNER JOIN MFHD_ITEM mi ON iv.ITEM_ID = mi.ITEM_ID
INNER JOIN mfhd_master mm ON mi.MFHD_ID = mm.MFHD_ID
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
--left OUTER JOIN CIRCCHARGES_VW ON mm.MFHD_ID = CIRCCHARGES_VW .MFHD_ID



WHERE   l.location_code LIKE 'cl%'
	-- i.perm_location = 108
	-- AND rih.effect_date >= TO_DATE('10/01/2015','MM/DD/YYYY')

   GROUP BY
--cta.charge_date,
mm.normalized_call_no,
bt.bib_id,
iv.item_id,
bt.isbn,
bt.author,
bt.title,
iv.enumeration,
bt.publisher,
l.LOCATION_CODE,
l.LOCATION_NAME,
bt.PUB_DATES_COMBINED,
--iv.create_date
TO_CHAR(iv.create_date,'YYYY-MM-DD')
--cta.discharge_date

  
  
 --  ORDER BY bt.title
   
   UNION ALL
   
   SELECT DISTINCT
Count (cta.charge_date) AS charges,
mm.normalized_call_no,
bt.bib_id,
iv.item_id,
bt.isbn,
bt.author,
bt.title,
iv.enumeration,
bt.publisher,
l.LOCATION_CODE,
l.LOCATION_NAME,
bt.PUB_DATES_COMBINED,
TO_CHAR(iv.create_date,'YYYY-MM-DD') AS acc_date,
Max (TO_CHAR(cta.discharge_date, 'YYYY-MM-DD')) AS last_discharge


    , case
    when exists (
        select *
        from bib_mfhd bm2
        inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
        inner join location l2 on mm2.location_id = l2.location_id
        where bm2.bib_id = bt.bib_id
        and l2.location_code = 'sr' --or like 'sr%', depending on your requirements
      ) then 'Y'
                else 'N'
end as has_srlf

, case
    when exists (
        select *
        from bib_mfhd bm3
        inner join mfhd_master mm3 on bm3.mfhd_id = mm3.mfhd_id
        inner join location l3 on mm3.location_id = l3.location_id
        where bm3.bib_id = bt.bib_id
        and l3.location_code not in ('cl', 'sr')
      ) then 'Y'
                else 'N'
end as has_other

FROM
 ITEM_vw iv
 left outer JOIN circ_trans_archive cta ON iv.ITEM_ID = cta.ITEM_ID
--INNER JOIN RESERVE_LIST_ITEMS rli ON i.ITEM_ID = rli.ITEM_ID
INNER JOIN BIB_ITEM bi ON iv.ITEM_ID = bi.ITEM_ID
INNER JOIN ucla_bibtext_vw bt ON bi.BIB_ID = bt.BIB_ID
INNER JOIN MFHD_ITEM mi ON iv.ITEM_ID = mi.ITEM_ID
INNER JOIN mfhd_master mm ON mi.MFHD_ID = mm.MFHD_ID
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
--left OUTER JOIN CIRCCHARGES_VW ON mm.MFHD_ID = CIRCCHARGES_VW .MFHD_ID



WHERE   l.location_code LIKE 'cl%'
	 AND NOT EXISTS (SELECT * FROM circcharges_vw WHERE mfhd_id = mm.mfhd_id)

   GROUP BY
  -- cta.charge_date,
mm.normalized_call_no,
bt.bib_id,
iv.item_id,
bt.isbn,
bt.author,
bt.title,
iv.enumeration,
bt.publisher,
l.LOCATION_CODE,
l.LOCATION_NAME,
bt.PUB_DATES_COMBINED,
--iv.create_date
TO_CHAR(iv.create_date,'YYYY-MM-DD')
--cta.discharge_date
	
   
  
  -- ORDER BY bt.title








