SELECT DISTINCT
--Max(cta.charge_date),
(select max(charge_date_only) from circcharges_vw where mfhd_id = cc.mfhd_id) as latest_charge,


 --(select max(charge_date_only
-- TO_CHAR(i.invoice_date,'fmMM/ DD/ YYYY')  inv_date
-- from circcharges_vw where mfhd_id = cc.mfhd_id) as latest_charge,

--l.location_name,
bt.bib_id,
--bt.issn,
--bt.isbn,
--mm.create_date,
it.item_type_name,
vger_support.unifix(bt.author) AS author,
vger_support.unifix(bt.title) AS title,
--bt.publisher,
--bt.pub_place,
--bt.publisher_date,
mm.normalized_call_no,
ib.item_barcode,
Count (DISTINCT i.item_id) AS items

--mi.item_enum,
--i.historical_charges,
--i.historical_browses
-- for testing
--i.item_id
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
        and l3.location_code not in ('ar', 'sr')
      ) then 'Y'
                else 'N'
end as has_other

--vger_support.renewals_from_date(i.item_id,to_date(#prompt('DATE1')#, 'YYYY-MM-DD')) AS renewal_count
FROM
ucladb.item i
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
l.location_code = 'ar'
AND it.item_type_name = 'Book'
--bt.bib_format = 'am'
AND normalized_call_no between vger_support.NormalizeCallNumber('P') and vger_support.NormalizeCallNumber('PZ')

GROUP BY
cc.charge_date_only,
--cta.charge_date,
 --(select max(charge_date_only) from circcharges_vw where mfhd_id = cc.mfhd_id) as latest_charge,

l.location_name,
bt.bib_id,
bt.issn,
bt.isbn,
mm.create_date,
vger_support.unifix(bt.author), --AS author,
vger_support.unifix(bt.title), --AS title,
bt.publisher,
bt.pub_place,
bt.publisher_date,
mm.normalized_call_no,
ib.item_barcode,
cc.mfhd_id,
it.item_type_name


ORDER BY mm.normalized_call_no
