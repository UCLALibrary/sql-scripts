SELECT DISTINCT
--cc.charge_date_only,
count(*) as charges,

(select max(charge_date_only) from circcharges_vw where mfhd_id = cc.mfhd_id) as latest_charge,

--l.location_code,
bt.bib_id,
 --count(*) as num,


bt.title,
bt.author,
bt.series,
ucladb.getbibtag(bt.Bib_id, '650') AS subject,
--bt.bib_format,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2 ) AS oclc_number,

mm.display_call_no,
--mm.normalized_call_no,

ib.item_barcode,
isty.item_status_desc AS item_status,
i.historical_charges

--Min (To_Char (cc.charge_date_only,'fmMM/ DD/ YYYY')) AS  charge_date


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
inner join ucla_bibtext_vw bt on bm.bib_id = bt.bib_id
INNER JOIN location l ON mm.location_id = l.location_id

WHERE
      bt.bib_format = 'am'
     -- AND bt.begin_pub_date < '2010'
     AND l.location_code = 'sm'
    --  AND (l.location_code = 'scav'  OR l.location_code = 'smav')
    -- AND NOT  EXISTS
      --   (select * from circcharges_vw where item_id = i.item_id
        --             and charge_date_only BETWEEN to_date('20050101', 'YYYYMMDD') AND  to_date('20171231', 'YYYYMMDD')
                       -- equals zero chargeouts before 2010

                     AND normalized_call_no between vger_support.NormalizeCallNumber('A') and vger_support.NormalizeCallNumber('QA 275%')

                   --  AND    isty.item_status_desc = 'Charged'
                  AND NOT EXISTS (select * from circcharges_vw where item_id = i.item_id
                    and charge_date_only BETWEEN to_date('20050101', 'YYYYMMDD') AND to_date('20171231', 'YYYYMMDD') )
GROUP BY
l.location_code,
cc.charge_date_only,
cc.mfhd_id,
 --count(*) as num,

bt.bib_id,
bt.title,
bt.author,
bt.series,
--bt.bib_format,
--(SELECT REPLACE(normal_heading, 'UCOCLC', '')
  --    FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2 ) AS oclc_number,

mm.display_call_no,
mm.normalized_call_no,
ib.item_barcode,
isty.item_status_desc, --AS item_status,
i.historical_charges



ORDER BY mm.display_call_no
