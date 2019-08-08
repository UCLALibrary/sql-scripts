NEW ITEMS
SELECT
  SYSDATE AS date_ran,
  l_p.location_display_name AS perm_location,
  vger_support.unifix(bt.title) AS title,
  bi.bib_id,
  mm.normalized_call_no AS call_no,
  mi.item_enum AS enumeration,
  ib.item_barcode,
  CASE
    WHEN bt.isbn IS NOT NULL THEN bt.isbn
    ELSE bt.issn
  END as isbn_or_issn,
  trim(bt.publisher) || ' ' || trim(bt.pub_place) || ' ' || trim(bt.publisher_date) AS pub_info,
  decode(bm.suppress_in_opac, 'Y', 'Yes', 'No') AS bib_suppressed,
  decode(mm.suppress_in_opac, 'Y', 'Yes', 'No') AS holding_suppressed,
  it_p.item_type_display AS item_type,
  l_t.location_display_name AS temp_location,
  it_t.item_type_display AS temp_type,
  i_note.item_note,
  i.create_date,
  ist.item_status_date AS status_date,
  i.historical_browses,
  vger_support.get_all_item_status(i.item_id) AS all_statuses
FROM
  ucladb.item i
  INNER JOIN ucladb.item_barcode ib ON i.item_id = ib.item_id
  INNER JOIN ucladb.item_type it_p ON i.item_type_id = it_p.item_type_id
  INNER JOIN ucladb.location l_p ON i.perm_location = l_p.location_id
  INNER JOIN ucladb.item_status ist ON i.item_id = ist.item_id
  INNER JOIN ucladb.bib_item bi ON i.item_id = bi.item_id
  INNER JOIN ucladb.bib_text bt ON bi.bib_id = bt.bib_id
  INNER JOIN ucladb.bib_master bm ON bi.bib_id = bm.bib_id
  INNER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
  INNER JOIN ucladb.mfhd_master mm ON mi.mfhd_id = mm.mfhd_id
  LEFT OUTER JOIN ucladb.location l_t ON i.temp_location = l_t.location_id
  LEFT OUTER JOIN ucladb.item_type it_t ON i.temp_item_type_id = it_t.item_type_id
  LEFT OUTER JOIN ucladb.item_note i_note ON i.item_id = i_note.item_id
WHERE
  substr(l_p.location_code, 1, 2) = 'cl'
  AND ist.item_status IN (1,11)
  AND trunc(i.create_date) >= trunc(sysdate - 30)
UNION
SELECT
  SYSDATE AS date_ran,
  l_p.location_display_name AS perm_location,
  vger_support.unifix(bt.title) AS title,
  bi.bib_id,
  mm.normalized_call_no AS call_no,
  mi.item_enum AS enumeration,
  ib.item_barcode,
  CASE
    WHEN bt.isbn IS NOT NULL THEN bt.isbn
    ELSE bt.issn
  END as isbn_or_issn,
  trim(bt.publisher) || ' ' || trim(bt.pub_place) || ' ' || trim(bt.publisher_date) AS pub_info,
  decode(bm.suppress_in_opac, 'Y', 'Yes', 'No') AS bib_suppressed,
  decode(mm.suppress_in_opac, 'Y', 'Yes', 'No') AS holding_suppressed,
  it_p.item_type_display AS item_type,
  l_t.location_display_name AS temp_location,
  it_t.item_type_display AS temp_type,
  i_note.item_note,
  i.create_date,
  ist.item_status_date AS status_date,
  i.historical_browses,
  vger_support.get_all_item_status(i.item_id) AS all_statuses
FROM
  ucladb.item i
  INNER JOIN ucladb.item_barcode ib ON i.item_id = ib.item_id
  INNER JOIN ucladb.item_type it_p ON i.item_type_id = it_p.item_type_id
  INNER JOIN ucladb.location l_p ON i.perm_location = l_p.location_id
  INNER JOIN ucladb.item_status ist ON i.item_id = ist.item_id
  INNER JOIN ucladb.bib_item bi ON i.item_id = bi.item_id
  INNER JOIN ucladb.bib_text bt ON bi.bib_id = bt.bib_id
  INNER JOIN ucladb.bib_master bm ON bi.bib_id = bm.bib_id
  INNER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
  INNER JOIN ucladb.mfhd_master mm ON mi.mfhd_id = mm.mfhd_id
  LEFT OUTER JOIN ucladb.location l_t ON i.temp_location = l_t.location_id
  LEFT OUTER JOIN ucladb.item_type it_t ON i.temp_item_type_id = it_t.item_type_id
  LEFT OUTER JOIN ucladb.item_note i_note ON i.item_id = i_note.item_id
WHERE
  substr(l_p.location_code, 1, 2) = 'cl'
  AND ist.item_status IN (1,11)
  AND vger_support.is_in_process(i.item_id) = 'T'


CHARGES DISCHARGES 1
select distinct
    sysdate as report_run,
    ib.item_barcode,
    bi.bib_id,
    p.institution_id,
--  pb.patron_barcode,
    greatest(coalesce(ct.charge_date, to_date('1980-01-01', 'YYYY-MM-DD')),coalesce(ct.discharge_date, to_date('1980-01-01', 'YYYY-MM-DD')),coalesce(is_h.item_status_date, to_date('1980-01-01', 'YYYY-MM-DD')),coalesce(is_td.item_status_date, to_date('1980-01-01', 'YYYY-MM-DD')),coalesce(is_th.item_status_date, to_date('1980-01-01', 'YYYY-MM-DD'))) as trans_date,
    ct.charge_date as charged,
    ct.discharge_date as discharged,
    is_h.item_status_date as on_hold,
    is_td.item_status_date as transit_discharged,
    is_th.item_status_date as transit_hold,
    lp.location_display_name as perm_location,
    lt.location_display_name as temp_location,
    vger_support.get_latest_item_status(i.item_id) as item_status,
    ct.charge_oper_id as charge_operator,
    ct.discharge_oper_id as discharge_operator
from
    ucladb.item i
    inner join ucladb.item_barcode ib on i.item_id = ib.item_id
    inner join ucladb.circ_transactions ct on ib.item_id = ct.item_id
    inner join ucladb.location lp on i.perm_location = lp.location_id
    inner join ucladb.patron p on ct.patron_id = p.patron_id
    --inner join ucladb.patron_barcode pb on ct.patron_group_id = pb.patron_group_id and ct.patron_id = pb.patron_id
    left outer join ucladb.location lt on i.temp_location = lt.location_id
    left outer join ucladb.item_status is_h on i.item_id = is_h.item_id and is_h.item_status = 7
    left outer join ucladb.item_status is_td on i.item_id = is_td.item_id and is_td.item_status = 9
    left outer join ucladb.item_status is_th on i.item_id = is_th.item_id and is_th.item_status = 10
    left outer join ucladb.bib_item bi on i.item_id = bi.item_id
where
    ct.charge_location = 111
    and trunc(ct.charge_date) = trunc(sysdate - 1)
-- between trunc(sysdate - 3) and trunc(sysdate - 1)
-- and pb.barcode_status = 1
union
select distinct
    sysdate as report_run,
    ib.item_barcode,
    bi.bib_id,
    p.institution_id,
--  pb.patron_barcode,
    greatest(coalesce(ct.charge_date, to_date('1980-01-01', 'YYYY-MM-DD')),coalesce(ct.discharge_date, to_date('1980-01-01', 'YYYY-MM-DD')),coalesce(is_h.item_status_date, to_date('1980-01-01', 'YYYY-MM-DD')),coalesce(is_td.item_status_date, to_date('1980-01-01', 'YYYY-MM-DD')),coalesce(is_th.item_status_date, to_date('1980-01-01', 'YYYY-MM-DD'))) as trans_date,
    ct.charge_date as charged,
    ct.discharge_date as discharged,
    is_h.item_status_date as on_hold,
    is_td.item_status_date as transit_discharged,
    is_th.item_status_date as transit_hold,
    lp.location_display_name as perm_location,
    lt.location_display_name as temp_location,
    vger_support.get_latest_item_status(i.item_id) as item_status,
    ct.charge_oper_id as charge_operator,
    ct.discharge_oper_id as discharge_operator
from
    ucladb.item i
    inner join ucladb.item_barcode ib on i.item_id = ib.item_id
    inner join ucladb.circ_trans_archive ct on ib.item_id = ct.item_id
    inner join ucladb.location lp on i.perm_location = lp.location_id
    inner join ucladb.patron p on ct.patron_id = p.patron_id
    --inner join ucladb.patron_barcode pb on ct.patron_group_id = pb.patron_group_id and ct.patron_id = pb.patron_id
    left outer join ucladb.location lt on i.temp_location = lt.location_id
    left outer join ucladb.item_status is_h on i.item_id = is_h.item_id and is_h.item_status = 7
    left outer join ucladb.item_status is_td on i.item_id = is_td.item_id and is_td.item_status = 9
    left outer join ucladb.item_status is_th on i.item_id = is_th.item_id and is_th.item_status = 10
    left outer join ucladb.bib_item bi on i.item_id = bi.item_id
where
    (ct.charge_location = 111 or ct.discharge_location = 111)
    and (
         trunc(ct.charge_date) = trunc(sysdate - 1)
--between trunc(sysdate - 3) and trunc(sysdate - 1) 
         or 
         trunc(ct.discharge_date) = trunc(sysdate - 1)
--between trunc(sysdate - 3) and trunc(sysdate - 1)
        )
--    and pb.barcode_status = 1

CHARGES DISCHARGES 2
select 
    sysdate AS report_run,
    bi.bib_id,
    ist.item_status_desc,
    itst.item_status_date,
    vger_support.routed_from(ist.item_status_desc, l_pickup.location_display_name, l_discharge.location_display_name) AS routed_from,
    vger_support.routed_to(ist.item_status_desc, l_pickup.location_display_name, l_h.location_display_name) AS routed_to,
    unifix(bt.author) AS author,
    unifix(bt.title) AS title, 
    iv.perm_location, 
    l_temp.location_display_name AS temp_location,
    cpg.circ_group_name,
    iv.call_no, 
    iv.barcode, 
    iv.enumeration,
    hr.create_opid
from 
    ucladb.bib_item bi 
    INNER JOIN ucladb.bib_text bt ON bi.bib_id = bt.bib_id
    INNER JOIN ucladb.item_vw iv ON bi.item_id = iv.item_id
    INNER JOIN ucladb.item i ON bi.item_id = i.item_id
    LEFT OUTER JOIN ucladb.location l_temp ON i.temp_location = l_temp.location_id
    LEFT OUTER JOIN ucladb.circ_trans_archive cta ON iv.item_id = cta.item_id
    INNER JOIN ucladb.item_status itst ON iv.item_id = itst.item_id
    INNER JOIN ucladb.item_status_type ist ON itst.item_status = ist.item_status_type
    LEFT OUTER JOIN ucladb.location l ON l.location_code = iv.perm_location_code
    LEFT OUTER JOIN ucladb.location l_discharge ON cta.discharge_location = l_discharge.location_id
    LEFT OUTER JOIN ucladb.hold_recall_items hri ON iv.item_id = hri.item_id
    LEFT OUTER JOIN ucladb.hold_recall hr ON hri.hold_recall_id = hr.hold_recall_id
    LEFT OUTER JOIN ucladb.location l_pickup ON hr.pickup_location = l_pickup.location_id
    LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON l.location_id = cpl.location_id
    LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
    LEFT OUTER JOIN ucladb.circ_policy_locs cpl_h ON cpl.circ_group_id = cpl_h.circ_group_id
    LEFT OUTER JOIN ucladb.location l_h ON cpl_h.location_id = l_h.location_id
WHERE 
-- Pick out the date range we're interested in
    trunc(item_status_date) = trunc(sysdate - 1)
-- Pick out the transaction for the item with the latest discharge date.
    AND NOT EXISTS
    (
        SELECT * FROM ucladb.circ_trans_archive cta2
        WHERE item_id = cta.item_id
        AND cta.discharge_date < cta2.discharge_date
    )
-- The documentation states we want "queue position 1" which means the entry with the highest queue_position value so pick this out.
    AND NOT EXISTS
    (
        SELECT * FROM ucladb.hold_recall_items hri2
        WHERE hri.item_id = hri2.item_id
        AND hri2.queue_position > hri.queue_position
    )
-- Pick out items with 'In Transit Discharged' (9) and 'In Transit On Hold' (10) statuses.
    AND (itst.item_status = 8 or itst.item_status = 9 or itst.item_status = 10)
-- Pick out the happening location for the item.
    AND (cpl_h.circ_location = 'Y' AND cpl_h.collect_fines = 'Y')
    AND (l.location_code like 'cl%' OR l_temp.location_code like 'cl%')
    --and vger_support.routed_from(ist.item_status_desc, l_pickup.location_display_name, l_discharge.location_display_name) like 'College%'
ORDER BY 
    cpg.circ_group_name, 
    iv.PERM_LOCATION, 
    iv.CALL_NO

CHARGES DISCHARGES 3
SELECT DISTINCT
      sysdate as report_run,
      bi.bib_id,
      ivw.barcode,
      p.last_name,
      p.first_name,
      SUBSTR(pb.patron_barcode, 1, 5) AS patron_barcode,
      ivw.enumeration,
      ivw.perm_location,
      ivw.gov_location,
      vger_support.Unifix(bt.title) AS title,
      CASE
          WHEN ivw.perm_location_code LIKE 'sr%' THEN '      ' || ivw.barcode    
          WHEN ivw.perm_location_code NOT LIKE 'sr%' AND NOT regexp_like(ivw.call_no, '^\*{1,}','i') THEN '     ' || ivw.call_no || ' ' || ivw.enumeration  
          WHEN ivw.perm_location_code NOT LIKE 'sr%' AND ivw.call_no IS NOT NULL AND regexp_like(ivw.call_no, '^\*{1,}','i')  AND vger_support.num_chars(ivw.call_no, '*') = 1 THEN '    ' || ivw.call_no || ' ' || ivw.enumeration
          WHEN ivw.perm_location_code NOT LIKE 'sr%' AND ivw.call_no IS NOT NULL AND regexp_like(ivw.call_no, '^\*{1,}','i')  AND vger_support.num_chars(ivw.call_no, '*') = 2 THEN '   ' || ivw.call_no || ' ' || ivw.enumeration
          WHEN ivw.perm_location_code NOT LIKE 'sr%' AND ivw.call_no IS NOT NULL AND regexp_like(ivw.call_no, '^\*{1,}','i')  AND vger_support.num_chars(ivw.call_no, '*') = 3 THEN '  ' || ivw.call_no || ' ' || ivw.enumeration
          ELSE ivw.call_no || ' ' || ivw.enumeration
      END AS barcode_or_call_no,
      --CASE
      --    WHEN ivw.perm_location_code LIKE 'sr%' THEN ' ' || ivw.barcode
      --    ELSE ivw.call_no || ' ' || ivw.enumeration
      --END AS barcode_or_call_no,
      hri.hold_recall_status_date,
      hr.expire_date,
      hr.create_opid,
      l.location_display_name,
      hr.patron_comment,
      vger_support.get_other_request(ivw.item_id,hr.hold_recall_id) AS other_requestor
FROM
    ucladb.hold_recall hr
    inner join ucladb.hold_recall_items hri ON hr.hold_recall_id = hri.hold_recall_id 
    inner join ucladb.patron p ON hr.patron_id = p.patron_id
    inner join ucladb.patron_barcode pb ON p.patron_id = pb.patron_id
    inner join ucladb.location l ON hr.pickup_location = l.location_id
    inner join ucladb.item_vw ivw ON hri.item_id = ivw.item_id
    inner join ucladb.bib_item bi ON ivw.item_id = bi.item_id
    inner join ucladb.bib_text bt ON bi.bib_id = bt.bib_id
    inner join ucladb.item_status ist ON hri.item_id = ist.item_id
WHERE
     hr.expire_date >= (SYSDATE - 14)
     AND (ist.item_status = 7)
     AND hri.queue_position = 1
     AND pb.barcode_status = 1
     AND trunc(ist.item_status_date) = trunc(sysdate - 1)
     AND l.location_code like 'cl%'


LOST LIBRARY APPLIED
SELECT
    ist.item_status_desc,
    itst.item_status_date,
    bt.bib_id,
    bt.isbn,
    bt.issn,
    unifix(bt.author) AS author,
    unifix(bt.title) AS title, 
    unifix(bt.edition) AS edition,
    unifix(bt.publisher) AS publisher,
    unifix(bt.pub_place) AS pub_place,
    unifix(bt.series) AS series,
    bt.publisher_date,
    iv.perm_location, 
    l_temp.location_display_name AS temp_location,
    cpg.circ_group_name,
    iv.call_no || ' ' || iv.enumeration AS call_num,
    iv.barcode,
    bm.suppress_in_opac AS bib_suppressed,
    mm.suppress_in_opac AS holding_suppressed
FROM
    ucladb.bib_item bi 
    INNER JOIN ucladb.bib_text bt ON bi.bib_id = bt.bib_id
    INNER JOIN ucladb.item i ON bi.item_id = i.item_id
    INNER JOIN ucladb.item_vw iv ON bi.item_id = iv.item_id
    LEFT OUTER JOIN ucladb.location l_temp ON i.temp_location = l_temp.location_id
    INNER JOIN ucladb.item_status itst ON iv.item_id = itst.item_id
    INNER JOIN ucladb.item_status_type ist ON itst.item_status = ist.item_status_type
    LEFT OUTER JOIN ucladb.location l ON l.location_code = iv.perm_location_code
    LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON l.location_id = cpl.location_id
    LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
    LEFT OUTER JOIN ucladb.bib_master bm ON bi.bib_id = bm.bib_id
    LEFT OUTER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
    LEFT OUTER JOIN ucladb.mfhd_master mm ON mi.mfhd_id = mm.mfhd_id
WHERE
    itst.item_status = '13'
    AND (iv.perm_location_code LIKE 'cl%' OR l_temp.location_code LIKE 'cl%')


COLLEGE ONLY PATRONS
SELECT
	pb.patron_barcode,
	pn.note,
	p.institution_id,
	p.create_date,
	p.expire_date
FROM
	ucladb.patron_barcode pb
	inner join ucladb.patron p ON pb.patron_id = p.patron_id
	left outer join ucladb.patron_notes pn ON p.patron_id = pn.patron_id 
WHERE
	pb.patron_group_id = 17
	AND pb.barcode_status = 1
--	AND pn.note_type = 1
ORDER BY
	patron_barcode


REFERENCE
SELECT
  SYSDATE AS date_ran,
  l_p.location_display_name AS perm_location,
  bt.title,
  bi.bib_id,
  mm.normalized_call_no AS call_no,
  mi.item_enum AS enumeration,
  ib.item_barcode,
  CASE
    WHEN bt.isbn IS NOT NULL THEN bt.isbn
    ELSE bt.issn
  END as isbn_or_issn,
  trim(bt.publisher) || ' ' || trim(bt.pub_place) || ' ' || trim(bt.publisher_date) AS pub_info,
  decode(bm.suppress_in_opac, 'Y', 'Yes', 'No') AS bib_suppressed,
  decode(mm.suppress_in_opac, 'Y', 'Yes', 'No') AS holding_suppressed,
  it_p.item_type_display AS item_type,
  l_t.location_display_name AS temp_location,
  it_t.item_type_display AS temp_type,
  i_note.item_note,
  i.create_date,
  ist.item_status_date AS status_date,
  i.historical_browses,
  vger_support.get_all_item_status(i.item_id) AS all_statuses
FROM
  ucladb.item i
  INNER JOIN ucladb.item_barcode ib ON i.item_id = ib.item_id
  INNER JOIN ucladb.item_type it_p ON i.item_type_id = it_p.item_type_id
  INNER JOIN ucladb.location l_p ON i.perm_location = l_p.location_id
  INNER JOIN ucladb.item_status ist ON i.item_id = ist.item_id
  INNER JOIN ucladb.bib_item bi ON i.item_id = bi.item_id
  INNER JOIN ucladb.bib_text bt ON bi.bib_id = bt.bib_id
  INNER JOIN ucladb.bib_master bm ON bi.bib_id = bm.bib_id
  INNER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
  INNER JOIN ucladb.mfhd_master mm ON mi.mfhd_id = mm.mfhd_id
  LEFT OUTER JOIN ucladb.location l_t ON i.temp_location = l_t.location_id
  LEFT OUTER JOIN ucladb.item_type it_t ON i.temp_item_type_id = it_t.item_type_id
  LEFT OUTER JOIN ucladb.item_note i_note ON i.item_id = i_note.item_id
WHERE
  i.perm_location IN (119,121,122,124,125,127,118,120,123,126,128)
  AND ist.item_status IN (1,11)


BROWSES NO CHARGES
SELECT
	vger_support.unifix(bt.author) AS author,
	vger_support.unifix(bt.title) AS title,
	bt.publisher,
	bt.pub_place,
	bt.publisher_date,
                     bt.publisher || ' ' || bt.pub_place || ' ' || bt.publisher_date AS pub_data,
	mm.normalized_call_no,
	i.historical_charges, 
	i.historical_browses
--,vger_support.renewals_from_date(i.item_id,to_date(#prompt('DATE1')#, 'YYYY-MM-DD')) AS renewal_count
FROM
	ucladb.item i
	inner join ucladb.bib_item bi on i.item_id = bi.item_id
	inner join ucladb.bib_text bt on bi.bib_id = bt.bib_id
	inner join ucladb.mfhd_item mi on i.item_id= mi.item_id
	inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
WHERE
	i.perm_location = 108
                    AND i.historical_charges = 0

CHARGES BROWSES RENEWALS
SELECT
	vger_support.unifix(bt.author) AS author,
	vger_support.unifix(bt.title) AS title,
	bt.publisher,
	bt.pub_place,
	bt.publisher_date,
                     bt.publisher || ' ' || bt.pub_place || ' ' || bt.publisher_date AS pub_data,
	mm.normalized_call_no,
	i.historical_charges, 
	i.historical_browses,
	vger_support.renewals_from_date(i.item_id,to_date(#prompt('DATE1')#, 'YYYY-MM-DD')) AS renewal_count
FROM
	ucladb.item i
	inner join ucladb.bib_item bi on i.item_id = bi.item_id
	inner join ucladb.bib_text bt on bi.bib_id = bt.bib_id
	inner join ucladb.mfhd_item mi on i.item_id= mi.item_id
	inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
WHERE
	i.perm_location = 108
	AND i.historical_charges <> 0


