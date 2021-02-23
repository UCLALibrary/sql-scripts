SELECT DISTINCT
mm.normalized_call_no,
ib.item_barcode,
vger_support.unifix(bt.title) AS title,
vger_support.unifix(bt.author) AS author,
bt.begin_pub_date as pub_date,
bt.bib_id,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
i.historical_charges,
--ista.item_status_desc,
Max (To_Char (cta.charge_date,'fmMM/ DD/ YYYY')) AS  charge_date

FROM
ucladb.item i
left outer JOIN circ_trans_archive cta ON i.ITEM_ID = cta.ITEM_ID
INNER JOIN ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_id
inner join ucladb.mfhd_item mi on i.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
INNER JOIN location l ON mm.location_id = l.location_id

inner join item_barcode ib on i.item_id = ib.item_id
inner join ITEM_TYPE it ON i.ITEM_TYPE_ID = it.ITEM_TYPE_ID
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID 
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE

WHERE     bt.bib_format = 'am'
            and bt.record_status = 'c' 
            and  (bt.begin_pub_date like '18%' 
              or bt.begin_pub_date like '19%' 
              or bt.begin_pub_date = '2000'
              or bt.begin_pub_date = '2001'
              or bt.begin_pub_date = '2002'
              or bt.begin_pub_date = '2003'
              or bt.begin_pub_date = '2004'
              or bt.begin_pub_date = '2005'
              or bt.begin_pub_date = '2006'
              or bt.begin_pub_date = '2007'
              or bt.begin_pub_date = '2008'
              or bt.begin_pub_date = '2009'
              or bt.begin_pub_date = '2010')
            and mm.normalized_call_no not like '*%'                                                          
            AND mm.suppress_in_opac = 'N'
            AND l.location_code =  --'cl' --or l.location_code = 
                                    'clcirc'
            AND normalized_call_no between vger_support.NormalizeCallNumber('A') and vger_support.NormalizeCallNumber('Z6972')
           -- AND ct.charge_date < to_date('20151231', 'YYYYMMDD')
            and cta.charge_date < to_date('20150101', 'YYYYMMDD')
            --between to_date('19990101', 'YYYYMMDD') and to_date('20141231', 'YYYYMMDD')
            

GROUP BY
--cta.charge_date,
ib.item_barcode,
mm.normalized_call_no,
mi.item_enum,
--ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'k'),
vger_support.unifix(bt.title),
vger_support.unifix(bt.author),
i.historical_charges,
bt.bib_id,
bt.begin_pub_date
--ista.item_status_desc


ORDER BY mm.normalized_call_no
