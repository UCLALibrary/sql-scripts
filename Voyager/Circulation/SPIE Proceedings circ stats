SELECT DISTINCT
bt.bib_id,
bt.title,
--bt.author,
bt.series,
--bt.bib_format,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2 ) AS oclc_number,

mm.display_call_no,
mm.normalized_call_no,
ib.item_barcode
--isty.item_status_desc AS item_status

--Min (To_Char (cc.charge_date_only,'fmMM/ DD/ YYYY')) AS  charge_date

, case
    when exists (
        select *
        from bib_mfhd bm2
        inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
        inner join location l2 on mm2.location_id = l2.location_id
        where bm2.bib_id = bt.bib_id
        and l2.location_code LIKE 'sr%' --or like 'sr%', depending on your requirements
      ) then 'Y'
                else 'N'
end has_sr






FROM
ucladb.item i
left outer JOIN circcharges_vw cc ON i.ITEM_ID = cc.ITEM_ID
INNER JOIN ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_id

inner join ucladb.ITEM_STATUS ist on i.ITEM_ID = ist.ITEM_ID
inner join ucladb.ITEM_STATUS_TYPE isty on ist.ITEM_STATUS = isty.ITEM_STATUS_TYPE
inner join ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_ID

inner join ucladb.mfhd_item mi on i.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
INNER JOIN location l ON mm.location_id = l.location_id

WHERE
    
       bt.series LIKE '%SPIE%'-- Proceedings%'

     
     AND l.location_code = 'sm'
     AND NOT EXISTS
         (select * from circcharges_vw where item_id = i.item_id
                     and charge_date_only > to_date('20100101', 'YYYYMMDD') )
