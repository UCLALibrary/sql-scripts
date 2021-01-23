
SELECT DISTINCT
mm.display_call_no,
ib.item_barcode,
bt.title,
bt.author,
bt.begin_pub_date as pub_date,
--bt.bib_id,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
bt.bib_id,
i.historical_charges, 
ista.item_status_desc
--mi.item_enum
--i.enumeration

FROM ucla_BIBTEXT_vw bt

INNER join BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER join MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
inner join LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
inner join MFHD_ITEM mi ON mm.MFHD_ID = mi.MFHD_ID
inner join ITEM i ON mi.ITEM_ID = i.ITEM_ID
inner join item_barcode ib on i.item_id = ib.item_id
inner join ITEM_TYPE it ON i.ITEM_TYPE_ID = it.ITEM_TYPE_ID
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID 
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE

--inner join CIRC_TRANS_archive ct ON i.ITEM_ID = ct.ITEM_ID

WHERE l.location_code = 'sciacq'
                        --'scujnl' 0 results
                        --'sctallm' 0 results
                        --'scscmorgan'
                        --'scrse' 0 results
                        --'scrf' 0 results
                        --'scper'
                        --'scof'
                        --'scmi' --0 results
                        --'sciselche' --0 results
                        --'sccrs' --0 results
                        --'scbook' --0 results
                        --'scbjnl'
                        --'scav' --0 results
                        --'scan' --0 results
                        --'sc' 
       
            order by mm.display_call_no
            
            
            
            
            
            
            
            
            
            

