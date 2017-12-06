WITH CHARGES_DISCHARGES AS
(
SELECT 
-- CIRC_TRANS_ARCHIVE for Chargeouts
  to_char(cta.charge_date,   'YYYY-MM') AS MONTH,
  decode(cta.patron_group_id,   0,   'No Group',   report_group_desc) AS group_name,
--  pg.patron_group_name as patron_group_name,
--  cpg.circ_group_name AS location,
  tl.location_name AS trans_location,
  il.location_name AS item_location,
  decode(cta.circ_transaction_id,   NULL,   0,   vger_support.lws_csc.IS_NOT_RESERVE_CHARGE(cta.charge_location, rst.on_reserve)) AS non_reserve_chargeout,
  decode(cta.circ_transaction_id,   NULL,   0,   vger_support.lws_csc.IS_RESERVE_CHARGE(cta.charge_location, rst.on_reserve)) AS reserve_chargeout,
  decode(cta.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_STAFF_CHARGE(cta.charge_location)) AS staff_chargeout,
  decode(cta.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_SELF_CHARGE(cta.charge_location)) AS self_chargeout,
  0 AS discharge,
  0 AS staff_renewal,
  0 as web_renewal
FROM ucladb.circ_trans_archive cta 
LEFT OUTER JOIN ucladb.location tl ON tl.location_id = cta.charge_location 
LEFT OUTER JOIN ucladb.item i ON i.item_id = cta.item_id 
LEFT OUTER JOIN ucladb.location il ON il.location_id = i.perm_location 
LEFT OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = cta.patron_group_id 
LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id 
--LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON cta.charge_location = cpl.location_id 
--LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON cta.circ_transaction_id = rst.circ_transaction_id
 AND cta.item_id = rst.item_id
WHERE trunc(cta.charge_date) BETWEEN trunc(to_date('2016-07-01','YYYY-MM-DD'))
  AND trunc(to_date('2017-06-30' ,'YYYY-MM-DD'))

UNION ALL

-- CIRC_TRANS_ARCHIVE for Discharges
SELECT 
  to_char(cta.discharge_date,   'YYYY-MM') AS MONTH,
  decode(cta.patron_group_id,   0,   'No Group',   report_group_desc) AS group_name,
--  pg.patron_group_name as patron_group_name,
--  cpg.circ_group_name AS location,
  tl.location_name AS trans_location,
  il.location_name AS item_location,
  0 AS non_reserve_chargeout,
  0 AS reserve_chargeout,
  0 AS staff_chargeout,
  0 AS self_chargeout,
  decode(cta.circ_transaction_id,   NULL,   0,   1) AS discharge,
  0 AS staff_renewal,
  0 as web_renewal
FROM ucladb.circ_trans_archive cta 
LEFT OUTER JOIN ucladb.location tl ON tl.location_id = cta.discharge_location 
LEFT OUTER JOIN ucladb.item i ON i.item_id = cta.item_id 
LEFT OUTER JOIN ucladb.location il ON il.location_id = i.perm_location 
LEFT OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = cta.patron_group_id 
LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id 
--LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON cta.discharge_location = cpl.location_id 
--LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON cta.circ_transaction_id = rst.circ_transaction_id
 AND cta.item_id = rst.item_id
WHERE cta.discharge_date BETWEEN trunc(to_date('2016-07-01','YYYY-MM-DD'))
  AND trunc(to_date('2017-06-30' ,'YYYY-MM-DD'))

UNION ALL

-- CIRC_TRANS_ARCHIVE for Renewals
SELECT 
  to_char(rta.renew_date,   'YYYY-MM') AS MONTH,
  decode(cta.patron_group_id,   0,   'No Group',   report_group_desc) AS group_name,
--  pg.patron_group_name as patron_group_name,
--  cpg.circ_group_name AS location,
  tl.location_name AS trans_location,
  il.location_name AS item_location,
  0 AS non_reserve_chargeout,
  0 AS reserve_chargeout,
  0 AS staff_chargeout,
  0 AS self_chargeout,
  0 AS discharge,
  decode(rta.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_STAFF_RENEWAL(rta.renew_oper_id)) AS staff_renewal,   
  decode(rta.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_WEB_RENEWAL(rta.renew_oper_id)) AS web_renewal
FROM ucladb.circ_trans_archive cta 
LEFT OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = cta.patron_group_id 
LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id
INNER JOIN ucladb.renew_trans_archive rta ON cta.circ_transaction_id = rta.circ_transaction_id 
LEFT OUTER JOIN ucladb.location tl ON tl.location_id = rta.renew_location 
LEFT OUTER JOIN ucladb.item i ON i.item_id = cta.item_id 
LEFT OUTER JOIN ucladb.location il ON il.location_id = i.perm_location 
--LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON rta.renew_location = cpl.location_id 
--LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON cta.circ_transaction_id = rst.circ_transaction_id
 AND cta.item_id = rst.item_id
WHERE rta.renew_date BETWEEN trunc(to_date('2016-07-01','YYYY-MM-DD'))
  AND trunc(to_date('2017-06-30' ,'YYYY-MM-DD'))

UNION ALL

-- CIRC_TRANSACTIONS for Chargeouts
SELECT 
  to_char(ct.charge_date,   'YYYY-MM') AS MONTH,
  decode(ct.patron_group_id,   0,   'No Group',   report_group_desc) AS group_name,
--  pg.patron_group_name as patron_group_name,
--  cpg.circ_group_name AS location,
  tl.location_name AS trans_location,
  il.location_name AS item_location,
  decode(ct.circ_transaction_id,   NULL,   0,   vger_support.lws_csc.IS_NOT_RESERVE_CHARGE(ct.charge_location, rst.on_reserve)) AS non_reserve_chargeout,
  decode(ct.circ_transaction_id,   NULL,   0,   vger_support.lws_csc.IS_RESERVE_CHARGE(ct.charge_location, rst.on_reserve)) AS reserve_chargeout,
  decode(ct.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_STAFF_CHARGE(ct.charge_location)) AS staff_chargeout,
  decode(ct.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_SELF_CHARGE(ct.charge_location)) AS self_chargeout,
  0 AS discharge,
  0 AS staff_renewal,
  0 as web_renewal
FROM ucladb.circ_transactions ct 
LEFT OUTER JOIN ucladb.location tl ON tl.location_id = ct.charge_location 
LEFT OUTER JOIN ucladb.item i ON i.item_id = ct.item_id 
LEFT OUTER JOIN ucladb.location il ON il.location_id = i.perm_location 
LEFT OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = ct.patron_group_id 
LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id 
--LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON ct.charge_location = cpl.location_id 
--LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON ct.circ_transaction_id = rst.circ_transaction_id
 AND ct.item_id = rst.item_id
WHERE ct.charge_date BETWEEN trunc(to_date('2016-07-01','YYYY-MM-DD'))
  AND trunc(to_date('2017-06-30' ,'YYYY-MM-DD'))

UNION ALL

-- CIRC_TRANSACTIONS for Renewals
SELECT 
  to_char(rt.renew_date,   'YYYY-MM') AS MONTH,
  decode(ct.patron_group_id,   0,   'No Group',   report_group_desc) AS group_name,
--  pg.patron_group_name as patron_group_name,
--  cpg.circ_group_name AS location,
  tl.location_name AS trans_location,
  il.location_name AS item_location,
  0 AS non_reserve_chargeout,
  0 AS reserve_chargeout,
  0 AS staff_chargeout,
  0 AS self_chargeout,
  0 AS discharge,
  decode(rt.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_STAFF_RENEWAL(rt.renew_oper_id)) AS staff_renewal,   
  decode(rt.circ_transaction_id,   NULL,   0,   vger_support.LWS_CSC.IS_WEB_RENEWAL(rt.renew_oper_id)) AS web_renewal
FROM ucladb.circ_transactions ct 
LEFT OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = ct.patron_group_id 
LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id
INNER JOIN ucladb.renew_transactions rt ON ct.circ_transaction_id = rt.circ_transaction_id 
LEFT OUTER JOIN ucladb.location tl ON tl.location_id = rt.renew_location 
LEFT OUTER JOIN ucladb.item i ON i.item_id = ct.item_id 
LEFT OUTER JOIN ucladb.location il ON il.location_id = i.perm_location 
--LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON rt.renew_location = cpl.location_id 
--LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON ct.circ_transaction_id = rst.circ_transaction_id
 AND ct.item_id = rst.item_id
WHERE rt.renew_date BETWEEN trunc(to_date('2016-07-01','YYYY-MM-DD'))
  AND trunc(to_date('2017-06-30' ,'YYYY-MM-DD'))
)
SELECT 
  '2016-07-01' AS fy_start,
  '2017-06-30' AS fy_end,
  group_name,
  SUM(non_reserve_chargeout) AS non_reserve_chargeout,
  SUM(reserve_chargeout) AS reserve_chargeout,
  SUM(discharge) AS discharge,
  SUM(staff_renewal) AS staff_renewal,
  SUM(web_renewal) AS web_renewal
FROM 
  CHARGES_DISCHARGES
WHERE trans_location = 'YRL Circulation Desk'
 AND(item_location LIKE 'EA %' OR item_location LIKE 'EAL %')
GROUP BY 
  '2016-07-01',
  '2017-06-30',
  group_name
ORDER BY 
  group_name

