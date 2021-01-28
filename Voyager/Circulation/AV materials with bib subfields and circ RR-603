SELECT   DISTINCT
  bt.bib_id,
  bt.TITLE,
  i.item_id,
  ist.item_status_desc,
   Count (cta.charge_date) AS charges,
   Max (TO_CHAR(cta.discharge_date, 'YYYY-MM-DD')) AS last_discharge,
   i.historical_charges,
l.location_name,
mm.display_call_no,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
  
bt.bib_format,
--substr(bt.bib_format, 2, 1) as bib_lvl,

ucladb.getbibtag(bt.Bib_id, '260') AS f260,
ucladb.getbibtag(bt.Bib_id, '264') AS f264,
bme.MEDIUM,
--LOCATION.LOCATION_NAME,
--Mfhd_Master.MFHD_ID,bt
ucladb.getbibsubfield(bt.bib_id, '300', 'a') AS F300a,
ucladb.getbibsubfield(bt.bib_id, '300', 'e') AS F300e,
ucladb.getbibsubfield(bt.bib_id, '306', 'a') AS F306a,
ucladb.getbibsubfield(bt.bib_id, '336', 'a') as f336a,
ucladb.getbibsubfield(bt.bib_id, '337', 'a') as f337a,
ucladb.getbibsubfield(bt.bib_id, '338', 'a') as f338a,
ucladb.getbibsubfield(bt.bib_id, '344', 'b') as f344b,
ucladb.getbibsubfield(bt.bib_id, '346', 'a') as f346a,
substr(bt.field_008, 19, 1) as f00818,
substr(bt.field_008, 20, 1) as f00819,
substr(bt.field_008, 21, 1) as f00820,
ucladb.getbibtag(bt.Bib_id, '910') AS f910,
ucladb.getbibtag(bt.Bib_id, '948') AS f948



--ucladb.getmfhdsubfield(Mfhd_master.mfhd_id, '300', 'a')  AS F300am

FROM
 ITEM i
 left OUTER JOIN circ_trans_archive cta ON i.ITEM_ID = cta.ITEM_ID

INNER JOIN BIB_ITEM bi ON i.ITEM_ID = bi.ITEM_ID
INNER JOIN ucla_bibtext_vw bt ON bi.BIB_ID = bt.BIB_ID
INNER JOIN BIB_MEDIUM bme ON bt.BIB_ID = bme.BIB_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID
INNER JOIN mfhd_master mm ON mi.MFHD_ID = mm.MFHD_ID
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
INNER JOIN ITEM_STATUS ista ON i.ITEM_ID = ista.ITEM_ID 
INNER JOIN ITEM_STATUS_TYPE ist ON ista.ITEM_STATUS = ist.ITEM_STATUS_TYPE
--left OUTER JOIN CIRCCHARGES_VW ON mm.MFHD_ID = CIRCCHARGES_VW .MFHD_ID

--AND NOT EXISTS (SELECT * FROM circcharges_vw WHERE mfhd_id = mm.mfhd_id)


WHERE   (bme.MEDIUM = 'm'
      OR bme.MEDIUM = 'c'
      OR bme.MEDIUM = 's'
      OR bme.MEDIUM = 'v')
      
      and (bib_format like 'g%'
       or bib_format like 'i%'
       or bib_format like 'j%'
       or bib_format like 'm%')
    
      and mm.suppress_in_opac = 'N'


group by
l.location_name,
mm.display_call_no,
bt.bib_format,
bt.bib_id,
bt.TITLE,
ucladb.getbibtag(bt.Bib_id, '260'),
ucladb.getbibtag(bt.Bib_id, '264'),
bme.MEDIUM,
ucladb.getbibsubfield(bt.bib_id, '300', 'a'),
ucladb.getbibsubfield(bt.bib_id, '300', 'e'),
ucladb.getbibsubfield(bt.bib_id, '306', 'a'),
ucladb.getbibsubfield(bt.bib_id, '336', 'a'),
ucladb.getbibsubfield(bt.bib_id, '337', 'a'),
ucladb.getbibsubfield(bt.bib_id, '338', 'a'),
ucladb.getbibsubfield(bt.bib_id, '344', 'b'),
ucladb.getbibsubfield(bt.bib_id, '346', 'a'),
substr(bt.field_008, 19, 1),
substr(bt.field_008, 20, 1),
substr(bt.field_008, 21, 1),
ucladb.getbibtag(bt.Bib_id, '910'),
ucladb.getbibtag(bt.Bib_id, '948'),
--(SELECT REPLACE(normal_heading, 'UCOCLC', '')
  --    FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  --),
  i.item_id,
  ist.item_status_desc,
  cta.charge_date,
  cta.discharge_date, 
  i.historical_charges


      
        order by bt.title
        


   --   AND  ucladb.getbibsubfield(ucla_bibtext_vw.bib_id, '300', 'e') IS NOT NULL

    -- ORDER BY ucladb.getbibsubfield(ucla_bibtext_vw.bib_id, '300', 'e')
    



