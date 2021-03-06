SELECT DISTINCT
mm.display_call_no,
bt.bib_id,
bt.title,
bt.author,
bt.series,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
  FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2 ) AS oclc_num,
ib.item_barcode,
isty.item_status_desc AS item_status,
Max  (To_Char (cc.charge_date_only,'fmMM/ DD/ YYYY')) AS  charge_date,
i.historical_browses


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
        l.location_code = 'sm'--'sgsclock'
                  AND bt.bib_format = 'am'
                  AND normalized_call_no between vger_support.NormalizeCallNumber('QA276') and vger_support.NormalizeCallNumber('QA612')
                  
                      AND charge_date_only >= to_date('20050101', 'YYYYMMDD') 
                      AND i.historical_browses = '0'
                     

 GROUP BY
bt.bib_id,
bt.title,
bt.author,
bt.series,
mm.display_call_no,
ib.item_barcode,
cc.charge_date_only,
isty.item_status_desc,
i.historical_browses


 ORDER BY mm.display_call_no
