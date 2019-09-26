--USE THIS - THIS IS THE GOOD ONE! LW OCT 2013
--normalized call number, author, title, Bib ID#, publisher, pub_date, Location_name, item barcode, item_type_name, historical charges, historical browses, and latest_charge. 
SELECT DISTINCT
Count (*) AS CHARGES,
Max (cta.charge_date) AS last_charge_date,
mm.normalized_call_no,
vger_support.unifix(bt.author) AS author,
vger_support.unifix(bt.title) AS title,
bt.bib_id,
vger_support.unifix(bt.publisher) AS publisher,
l.location_name,
ib.item_barcode,
it.item_type_name,
i.historical_charges,
i.historical_browses

--'' AS placeholder,

FROM ucla_bibtext_vw bt

INNER JOIN BIB_MFHD ON bt.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER  mm
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID ON BIB_MFHD.MFHD_ID = mm.MFHD_ID
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
INNER JOIN ITEM i on mi.item_id = i.item_id
INNER JOIN ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_ID
left outer JOIN ITEM_TYPE it ON i.ITEM_ID = it.ITEM_TYPE_ID

inner JOIN circ_trans_archive cta ON i.item_id = cta.item_id


             where 
                l.location_code = 'yr'--like 'lw%'
                AND normalized_call_no between vger_support.NormalizeCallNumber('M')
                and vger_support.NormalizeCallNumber('MZ')
             
            group by
cta.charge_date,
mm.normalized_call_no,
vger_support.unifix(bt.author),
vger_support.unifix(bt.title),
bt.bib_id,
vger_support.unifix(bt.publisher),
l.location_name,
ib.item_barcode,
it.item_type_name,
i.historical_charges,
i.historical_browses

ORDER BY  
mm.normalized_call_no

union all 

SELECT DISTINCT
--Count (*) AS CHARGES,
'0' AS charges,
' ' as last_charge_date,
--(select max(charge_date_only) from circcharges_vw cc where mfhd_id = cc.mfhd_id) as latest_charge,
mm.normalized_call_no,
vger_support.unifix(bt.author) AS author,
vger_support.unifix(bt.title) AS title,
bt.bib_id,
vger_support.unifix(bt.publisher) AS publisher,
l.location_name,
ib.item_barcode,
it.item_type_name,
i.historical_charges,
i.historical_browses


FROM ucla_bibtext_vw bt


left outer join BIB_MFHD ON bt.BIB_ID = BIB_MFHD.BIB_ID
left outer join MFHD_MASTER  mm
left outer join CIRCCHARGES_VW cc ON mm.MFHD_ID = cc.MFHD_ID

left outer join LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID ON BIB_MFHD.MFHD_ID = mm.MFHD_ID
left outer join ITEM i
left outer join MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID ON mm.MFHD_ID = mi.MFHD_ID
left OUTER JOIN ITEM_TYPE it ON i.ITEM_TYPE_ID = it.ITEM_TYPE_ID

left outer JOIN ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_ID
left OUTER JOIN ITEM_BARCODE_STATUS ibs ON ib.BARCODE_STATUS = ibs.BARCODE_STATUS_TYPE



            WHERE l.location_code = 'yr'
            AND normalized_call_no between vger_support.NormalizeCallNumber('M')
                and vger_support.NormalizeCallNumber('MZ')
            
              --    and cc.charge_date_only > to_date('20090531', 'YYYYMMDD')
           AND NOT EXISTS (SELECT * FROM circcharges_vw cc WHERE mfhd_id = mm.mfhd_id)

GROUP BY
mm.normalized_call_no,
vger_support.unifix(bt.author),
vger_support.unifix(bt.title),
bt.bib_id,
vger_support.unifix(bt.publisher),
l.location_name,
ib.item_barcode,
it.item_type_name,
i.historical_charges,
i.historical_browses,
cc.charge_date_only



ORDER BY  mm.normalized_call_no


