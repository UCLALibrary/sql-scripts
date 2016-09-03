SELECT DISTINCT
bt.bib_id,
bt.title,
bt.author,
bt.series,
--bt.bib_format,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2 ) AS oclc_number,

mm.display_call_no,
ib.item_barcode,
isty.item_status_desc AS item_status

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
      bt.bib_format = 'am'
      AND l.location_code = 'sg'
     AND NOT EXISTS
         (select * from circcharges_vw where item_id = i.item_id
                     and charge_date_only < to_date('20100101', 'YYYYMMDD') )  -- equals zero chargeouts before 2010

                     AND normalized_call_no between vger_support.NormalizeCallNumber('QE1') and vger_support.NormalizeCallNumber('Z')

GROUP BY
bt.bib_id,
bt.title,
bt.author,
bt.series,
--bt.bib_format,
mm.display_call_no,
mi.item_enum,
--ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'k') AS f852k,
vger_support.unifix(bt.title),
ib.item_barcode,
--mm.create_date AS acq_date,
--i.historical_charges,
cc.charge_date_only,
isty.item_status_desc


 ORDER BY mm.display_call_no
