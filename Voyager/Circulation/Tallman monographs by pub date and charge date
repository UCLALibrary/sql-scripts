SELECT DISTINCT
--Count (cc.charge_date_only) AS charges,
--Count (*) AS charges,
i.historical_charges,
bt.title,
bt.author,
bt.publisher_date,
bt.network_number AS oclc_num,

mm.normalized_call_no,
ib.item_barcode,
istt.item_status_desc
--vger_support.renewals_from_date(i.item_id,to_date(#prompt('DATE1')#, 'YYYY-MM-DD')) AS renewal_count
FROM
ucladb.item i
INNER JOIN ITEM_STATUS ista ON i.ITEM_ID = ista.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE istt ON ista.ITEM_STATUS = istt.ITEM_STATUS_TYPE

--INNER JOIN ITEM_STATUS_TYPE ON ITEM_STATUS.ITEM_STATUS = ITEM_STATUS_TYPE.ITEM_STATUS_TYPE) INNER JOIN ITEM ON ITEM_STATUS.ITEM_ID = ITEM.ITEM_ID


--left outer JOIN circ_trans_archive cta ON i.ITEM_ID = cta.ITEM_ID
INNER JOIN ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_id
INNER JOIN ITEM_TYPE it ON i.ITEM_TYPE_ID = it.ITEM_TYPE_ID
inner join ucladb.mfhd_item mi on i.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
INNER JOIN location l ON mm.location_id = l.location_id
left OUTER JOIN CIRCCHARGES_VW cc ON mm.MFHD_ID = cc.MFHD_ID

WHERE
bt.publisher_date < '2011'
AND l.location_code = 'smsctallm'
AND cc.charge_date_only < to_date('20110101', 'YYYYMMDD')
GROUP BY
cc.charge_date_only,
--cta.charge_date,
 --(select max(charge_date_only) from circcharges_vw where mfhd_id = cc.mfhd_id) as latest_charge,

l.location_name,
bt.bib_id,
bt.network_number,
bt.pub_place,
bt.publisher_date,
mm.normalized_call_no,
ib.item_barcode,
--cc.mfhd_id,
--it.item_type_name,
bt.title,
bt.author,
i.historical_charges,
istt.item_status_desc,
cc.charge_date_only



ORDER BY mm.normalized_call_no




