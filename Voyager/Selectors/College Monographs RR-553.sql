SELECT DISTINCT
mm.normalized_call_no,
(select count(*) from circ_trans_archive where item_id = i.item_id) AS charges,
ib.item_barcode,
vger_support.unifix(bt.title) AS title,
vger_support.unifix(bt.author) AS author,
bt.begin_pub_date as pub_date,
bt.bib_id,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
i.historical_charges,
(select max(discharge_date) from circ_trans_archive where item_id = i.item_id) as last_tranasaction,
ista.item_status_desc,
 ( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from bib_location bl
    inner join location l2 on bl.location_id = l2.location_id
    where bl.bib_id = bt.bib_id
    and l2.location_code != l.location_code
) as other_locs



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
--inner join ITEM_TYPE it ON i.ITEM_TYPE_ID = it.ITEM_TYPE_ID
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
            AND l.location_code =  'cl' or l.location_code = 'clcirc'
            AND normalized_call_no between vger_support.NormalizeCallNumber('A') and vger_support.NormalizeCallNumber('Z6972')
                       and cta.discharge_date < to_date('20150101', 'YYYYMMDD')
           
            

ORDER BY mm.normalized_call_no
