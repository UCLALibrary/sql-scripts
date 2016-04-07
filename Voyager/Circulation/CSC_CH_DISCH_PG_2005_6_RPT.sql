
REM VGER_SUPPORT CSC_CH_DISCH_PG_2005_6_RPT

  CREATE OR REPLACE FORCE VIEW "VGER_SUPPORT"."CSC_CH_DISCH_PG_2005_6_RPT" ("LOCATION", "GROUP_NAME", "PATRON_GROUP_NAME", "NON_RESERVE_CHARGEOUT", "RESERVE_CHARGEOUT", "DISCHARGE", "STAFF_RENEWAL", "WEB_RENEWAL") AS 
  SELECT location, group_name, patron_group_name,
  SUM(non_reserve_chargeout) AS
non_reserve_chargeout,
  SUM(reserve_chargeout) AS
reserve_chargeout,
  SUM(discharge) AS
discharge,
  SUM(staff_renewal) AS
staff_renewal,
  SUM(web_renewal) AS
web_renewal
FROM vger_report.csc_charge_discharge_2005_6_mv
GROUP BY location, group_name, patron_group_name
ORDER BY location, group_name, patron_group_name;
 