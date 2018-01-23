courses
SELECT
  i.last_name  || ' : ' || c.course_name || ' (' || d.DEPARTMENT_NAME || ')' AS course_prof,
  rlc.reserve_list_id
FROM
  ucladb.reserve_list_courses rlc
  INNER JOIN ucladb.reserve_list rl ON rlc.reserve_list_id = rl.reserve_list_id
  INNER JOIN ucladb.instructor i ON rlc.instructor_id = i.instructor_id
  INNER JOIN ucladb.course c ON rlc.course_id = c.course_id
  INNER JOIN ucladb.DEPARTMENT d ON rlc.DEPARTMENT_ID = d.DEPARTMENT_ID
WHERE 
  rl.effect_date <= SYSDATE
  AND rl.expire_date >= SYSDATE
ORDER BY
  course_prof


items
WITH CHARGES_DISCHARGES AS
(
SELECT 
-- CIRC_TRANS_ARCHIVE for Chargeouts
  cta.item_id,
  decode(cta.circ_transaction_id,   NULL,   0,   vger_support.lws_csc.IS_NOT_RESERVE_CHARGE(cta.charge_location, rst.on_reserve)) AS non_reserve_chargeout,
  decode(cta.circ_transaction_id,   NULL,   0,   vger_support.lws_csc.IS_RESERVE_CHARGE(cta.charge_location, rst.on_reserve)) AS reserve_chargeout,
  decode(cta.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_STAFF_CHARGE(cta.charge_location)) AS staff_chargeout,
  decode(cta.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_SELF_CHARGE(cta.charge_location)) AS self_chargeout,
  0 AS discharge,
  0 AS staff_renewal,
  0 as web_renewal
FROM 
  ucladb.circ_trans_archive cta 
  INNER JOIN ucladb.reserve_list_items rli ON cta.item_id = rli.item_id
  LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON cta.circ_transaction_id = rst.circ_transaction_id AND cta.item_id = rst.item_id
WHERE 
  trunc(cta.charge_date) BETWEEN trunc(to_date(#prompt('STARTDATE')#, 'YYYY-MM-DD')) and trunc(to_date(#prompt('ENDDATE')#, 'YYYY-MM-DD'))
  AND rli.RESERVE_LIST_ID = #prompt('COURSE')#

UNION ALL

-- CIRC_TRANS_ARCHIVE for Discharges
SELECT 
  cta.item_id,
  0 AS non_reserve_chargeout,
  0 AS reserve_chargeout,
  0 AS staff_chargeout,
  0 AS self_chargeout,
  decode(cta.circ_transaction_id,   NULL,   0,   1) AS discharge,
  0 AS staff_renewal,
  0 as web_renewal
FROM 
  ucladb.circ_trans_archive cta 
  INNER JOIN ucladb.reserve_list_items rli ON cta.item_id = rli.item_id
  LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON cta.circ_transaction_id = rst.circ_transaction_id AND cta.item_id = rst.item_id
WHERE 
  trunc(cta.discharge_date) BETWEEN trunc(to_date(#prompt('STARTDATE')#, 'YYYY-MM-DD')) and trunc(to_date(#prompt('ENDDATE')#, 'YYYY-MM-DD'))
  AND rli.RESERVE_LIST_ID = #prompt('COURSE')#

UNION ALL

-- CIRC_TRANS_ARCHIVE for Renewals
SELECT 
  cta.item_id,
  0 AS non_reserve_chargeout,
  0 AS reserve_chargeout,
  0 AS staff_chargeout,
  0 AS self_chargeout,
  0 AS discharge,
  decode(rta.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_STAFF_RENEWAL(rta.renew_oper_id)) AS staff_renewal,   
  decode(rta.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_WEB_RENEWAL(rta.renew_oper_id)) AS web_renewal
FROM 
  ucladb.circ_trans_archive cta 
  INNER JOIN ucladb.reserve_list_items rli ON cta.item_id = rli.item_id
  INNER JOIN ucladb.renew_trans_archive rta ON cta.circ_transaction_id = rta.circ_transaction_id 
  LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON cta.circ_transaction_id = rst.circ_transaction_id AND cta.item_id = rst.item_id
WHERE 
  trunc(rta.renew_date) BETWEEN trunc(to_date(#prompt('STARTDATE')#, 'YYYY-MM-DD')) and trunc(to_date(#prompt('ENDDATE')#, 'YYYY-MM-DD'))
  AND rli.RESERVE_LIST_ID = #prompt('COURSE')#

UNION ALL

-- CIRC_TRANSACTIONS for Chargeouts
SELECT 
  ct.item_id,
  decode(ct.circ_transaction_id,   NULL,   0,   vger_support.lws_csc.IS_NOT_RESERVE_CHARGE(ct.charge_location, rst.on_reserve)) AS non_reserve_chargeout,
  decode(ct.circ_transaction_id,   NULL,   0,   vger_support.lws_csc.IS_RESERVE_CHARGE(ct.charge_location, rst.on_reserve)) AS reserve_chargeout,
  decode(ct.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_STAFF_CHARGE(ct.charge_location)) AS staff_chargeout,
  decode(ct.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_SELF_CHARGE(ct.charge_location)) AS self_chargeout,
  0 AS discharge,
  0 AS staff_renewal,
  0 as web_renewal
FROM 
  ucladb.circ_transactions ct 
  INNER JOIN ucladb.reserve_list_items rli ON ct.item_id = rli.item_id
  LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON ct.circ_transaction_id = rst.circ_transaction_id AND ct.item_id = rst.item_id
WHERE 
  trunc(ct.charge_date) BETWEEN trunc(to_date(#prompt('STARTDATE')#, 'YYYY-MM-DD')) and trunc(to_date(#prompt('ENDDATE')#, 'YYYY-MM-DD'))
  AND rli.RESERVE_LIST_ID = #prompt('COURSE')#

UNION ALL

-- CIRC_TRANSACTIONS for Renewals
SELECT 
  ct.item_id,
  0 AS non_reserve_chargeout,
  0 AS reserve_chargeout,
  0 AS staff_chargeout,
  0 AS self_chargeout,
  0 AS discharge,
  decode(rt.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_STAFF_RENEWAL(rt.renew_oper_id)) AS staff_renewal,   
  decode(rt.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_WEB_RENEWAL(rt.renew_oper_id)) AS web_renewal
FROM 
  ucladb.circ_transactions ct 
  INNER JOIN ucladb.reserve_list_items rli ON ct.item_id = rli.item_id
  INNER JOIN ucladb.renew_transactions rt ON ct.circ_transaction_id = rt.circ_transaction_id 
  LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON ct.circ_transaction_id = rst.circ_transaction_id AND ct.item_id = rst.item_id
WHERE 
  trunc(rt.renew_date) BETWEEN trunc(to_date(#prompt('STARTDATE')#, 'YYYY-MM-DD')) and trunc(to_date(#prompt('ENDDATE')#, 'YYYY-MM-DD'))
  AND rli.RESERVE_LIST_ID = #prompt('COURSE')#
)
SELECT 
  title,
  SUM(non_reserve_chargeout) AS non_reserve_chargeout,
  SUM(reserve_chargeout) AS reserve_chargeout,
  SUM(discharge) AS discharge,
  SUM(staff_renewal) AS staff_renewal,
  SUM(web_renewal) AS web_renewal
FROM 
  charges_discharges cd
  INNER JOIN ucladb.bib_item bi ON cd.item_id = bi.item_id
  INNER JOIN ucladb.bib_text bt ON bi.bib_id = bt.bib_id
GROUP BY 
  title
ORDER BY 
  title
