
REM VGER_SUPPORT CSC_CH_DISCH_EAL_2005_6_RPT

  CREATE OR REPLACE FORCE VIEW "VGER_SUPPORT"."CSC_CH_DISCH_EAL_2005_6_RPT" ("GROUP_NAME", "NON_RESERVE_CHARGEOUT", "RESERVE_CHARGEOUT", "DISCHARGE", "STAFF_RENEWAL", "WEB_RENEWAL") AS 
  SELECT group_name,
  SUM(non_reserve_chargeout) AS
non_reserve_chargeout,
  SUM(reserve_chargeout) AS
reserve_chargeout,
  SUM(discharge) AS
discharge,
sum(staff_renewal) as staff_renewal,
sum(web_renewal) as web_renewal
FROM vger_report.csc_charge_discharge_2005_6_mv
WHERE trans_location = 'YRL Circulation Desk'
 AND(item_location LIKE 'EA %' OR item_location LIKE 'EAL %')
GROUP BY group_name
ORDER BY group_name;
 