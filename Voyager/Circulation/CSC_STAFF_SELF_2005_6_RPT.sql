
REM VGER_SUPPORT CSC_STAFF_SELF_2005_6_RPT

  CREATE OR REPLACE FORCE VIEW "VGER_SUPPORT"."CSC_STAFF_SELF_2005_6_RPT" ("LOCATION", "MONTH", "STAFF_CHARGEOUT", "SELF_CHARGEOUT") AS 
  SELECT location,
  MONTH,
  SUM(staff_chargeout) AS
staff_chargeout,
  SUM(self_chargeout) AS
self_chargeout
FROM vger_report.csc_charge_discharge_2005_6_mv
WHERE(location = 'YRL' OR location = 'Biomedical Library' OR location = 'College Library')
 AND MONTH <> '2005-07'
 AND MONTH <> '2005-08'
 AND MONTH <> '2005-09'
GROUP BY location,
  MONTH
ORDER BY location,
  MONTH;
 