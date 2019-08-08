SELECT DISTINCT
mm.normalized_call_no,
mi.item_enum,
ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'k') AS f852k,
vger_support.unifix(bt.title) AS title,
ib.item_barcode,
mm.create_date AS acq_date,
i.historical_charges,
--Max (To_Char (cta.charge_date,'fmMM/ DD/ YYYY')) AS  charge_date

TO_CHAR(MAX(cta.charge_date), 'fmMM/ DD/ YYYY') as last_charge_date




, case
    when exists (
        select *
        from bib_mfhd bm2
        inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
        inner join location l2 on mm2.location_id = l2.location_id
        where bm2.bib_id = bt.bib_id
        and l2.location_name LIKE  '%Reserves%' --or like 'sr%', depending on your requirements
      ) then 'Y'
                else 'N'
end has_reserves

, case
    when exists (
        select *
        from bib_mfhd bm2
        inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
        inner join location l2 on mm2.location_id = l2.location_id
        where bm2.bib_id = bt.bib_id
        and l2.location_code != 'cl' --or like 'sr%', depending on your requirements
      ) then 'Y'
                else 'N'
end has_other



--vger_support.renewals_from_date(i.item_id,to_date(#prompt('DATE1')#, 'YYYY-MM-DD')) AS renewal_count
FROM
ucladb.item i
left outer JOIN circ_trans_archive cta ON i.ITEM_ID = cta.ITEM_ID
INNER JOIN ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_id
inner join ucladb.mfhd_item mi on i.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
INNER JOIN location l ON mm.location_id = l.location_id
WHERE l.location_code = 'cl'  --AND ib.item_barcode = 'L0054540455'

GROUP BY
mm.normalized_call_no,
mi.item_enum,
ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'k'),
vger_support.unifix(bt.title),
ib.item_barcode,
mm.create_date,
i.historical_charges,
--cta.charge_date,
bt.bib_id

ORDER BY mm.normalized_call_no
