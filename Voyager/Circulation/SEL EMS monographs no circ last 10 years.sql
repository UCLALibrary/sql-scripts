SELECT DISTINCT
mm.display_call_no,
ib.item_barcode,
bt.TITLE,
bt.author,
bt.series,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
bt.bib_id,
isty.item_status_desc AS item_status


FROM ucla_bibtext_vw bt


inner join BIB_MFHD ON bt.BIB_ID = BIB_MFHD.BIB_ID
inner join MFHD_MASTER  mm
inner join LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID ON BIB_MFHD.MFHD_ID = mm.MFHD_ID
inner join ITEM i
inner join MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID ON mm.MFHD_ID = mi.MFHD_ID


inner join ucladb.ITEM_STATUS ist on i.ITEM_ID = ist.ITEM_ID
inner join ucladb.ITEM_STATUS_TYPE isty on ist.ITEM_STATUS = isty.ITEM_STATUS_TYPE
inner join ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_ID



            WHERE l.location_code = 'sm'
                  AND bt.bib_format = 'am'
                  AND normalized_call_no between vger_support.NormalizeCallNumber('QA276') and vger_support.NormalizeCallNumber('QA612')
                  AND NOT EXISTS (select * from circcharges_vw where item_id = i.item_id
                      AND charge_date_only >= to_date('20050101', 'YYYYMMDD') )


ORDER BY  mm.display_call_no
