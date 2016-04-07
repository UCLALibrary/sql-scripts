
REM VGER_SUPPORT CSC_FINES_2005_6_RPT

  CREATE OR REPLACE FORCE VIEW "VGER_SUPPORT"."CSC_FINES_2005_6_RPT" ("LOCATION", "OVERDUE", "OVERDUE_PAYMENT", "OVERDUE_FORGIVE", "LOST_ITEM_REPLACEMENT", "LOST_ITEM_REPLACEMENT_PAYMENT", "LOST_ITEM_REPLACEMENT_FORGIVE") AS 
  select 
location,
sum(overdue) as overdue,
sum(overdue_payment) as overdue_payment,
sum(overdue_forgive) as overdue_forgive,
sum(lost_item_replacement) as lost_item_replacement,
sum(lost_item_replacement_payment) as lost_item_replacement_payment,
sum(lost_item_replacement_forgive) as lost_item_replacement_forgive
from vger_report.csc_fines_2005_6_mv
group by location;
 