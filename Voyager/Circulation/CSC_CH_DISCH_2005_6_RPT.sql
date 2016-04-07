
REM VGER_SUPPORT CSC_CH_DISCH_2005_6_RPT

  CREATE OR REPLACE FORCE VIEW "VGER_SUPPORT"."CSC_CH_DISCH_2005_6_RPT" ("LOCATION", "GROUP_NAME", "NON_RESERVE_CHARGEOUT", "RESERVE_CHARGEOUT", "DISCHARGE", "STAFF_RENEWAL", "WEB_RENEWAL") AS 
  select 
location,
group_name,
sum(non_reserve_chargeout) as non_reserve_chargeout,
sum(reserve_chargeout) as reserve_chargeout,
sum(discharge) as discharge,
sum(staff_renewal) as staff_renewal,
sum(web_renewal) as web_renewal
from vger_report.csc_charge_discharge_2005_6_mv
group by 
location, group_name
order by location,group_name;
 