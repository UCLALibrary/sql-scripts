
SELECT DISTINCT
mm.display_call_no,
ib.item_barcode,
--bt.bib_format,
--bt.record_status,
--bt.encoding_level,
bt.title,
mi.item_enum,
bt.author,
bt.pub_dates_combined as pub_date,
bt.series,
ucladb.getallbibtag(bt.bib_id, '650') AS subjects,

--bt.begin_pub_date as pub_date,
--bt.bib_id,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
bt.bib_id,
i.historical_charges as total_charges, 
max(ct.charge_date)as last_charge_date,
 ( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from bib_location bl
    inner join location l2 on bl.location_id = l2.location_id
    where bl.bib_id = bt.bib_id
    and l2.location_code != l.location_code
) as other_locs,
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

left outer join CIRC_TRANS_archive ct ON i.ITEM_ID = ct.ITEM_ID

WHERE 
        bt.bib_format = 'as'
        and bt.record_status = 'c'
        and l.location_code in ('sgujnl', 'sgper', 'sgperwt', 'sgdi', 'sgdisp', 'sgdispwt', 'sgnews', 'sgnewltr', 'scujnl')
        
        -- = 'sgmi'
        --in ('sgrf', 'sgrfabst', 'sgrfatlslo', 'sgrfatlssh', 'sgrfelec')
        --   ('sgrf', 'sgrfabst', 'sgrfatlslo', 'sgrfatlssh', 'sgrfelec')
        
        group by
        mm.display_call_no,
ib.item_barcode,
bt.bib_format,
bt.title,
bt.author,
--bt.begin_pub_date,
--bt.bib_id,
--(SELECT REPLACE(normal_heading, 'UCOCLC', '')
  --    FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  --),
bt.bib_id,
i.historical_charges, 
ct.charge_date,
l.location_code,
bt.record_status,
bt.encoding_level,
bt.series,
ista.item_status_desc,
mi.item_enum,

--ista.item_status_desc
--mi.item_enum
--i.enumeration
bt.pub_dates_combined
        order by mm.display_call_no
        
        



            
            
            
            

