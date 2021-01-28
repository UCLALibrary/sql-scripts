--RR-363 CLICC Circulation Transactions
SELECT DISTINCT

substr(bt.bib_format, 2, 1) as bib_lvl,
bt.bib_id,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
l.location_code,
i.item_id,
ib.item_barcode,
mm.mfhd_id,
bt.title,
bt.author,
bt.publisher,
bt.pub_place,
bt.edition,
bt.begin_pub_date,
bt.language,
mm.normalized_call_no,
mm.display_call_no,
mi.ITEM_ENUM

FROM ucla_BIBTEXT_vw bt

INNER join BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER join MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
inner join LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
inner join MFHD_ITEM mi ON mm.MFHD_ID = mi.MFHD_ID
inner join ITEM i ON mi.ITEM_ID = i.ITEM_ID
inner join item_barcode ib on i.item_id = ib.item_id
--inner join ITEM_TYPE it ON i.ITEM_TYPE_ID = it.ITEM_TYPE_ID
--INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID 
--INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE


WHERE        --   bt.bib_format = 'am'
           -- and bt.record_status = 'c' 
           
             
            mm.normalized_call_no not like '*%'                                                          
            AND mm.suppress_in_opac = 'N'
            AND   l.location_code = 'yrgic'
               or l.location_code = 'yrmapat'
               or l.location_code = 'yrof'
               or l.location_code = 'yrofbibs'
               or l.location_code = 'yrofrf'
               or l.location_code = 'yrofrfcd'
               or l.location_code = 'yrofrfco'
               
            
             
            order by mm.normalized_call_no, mi.ITEM_ENUM
            
            

