/*  Tax and Freight fund code report for LBS
    RR-653
*/

select
  fiscal_period_name as fiscal_year
, ledger_name
, fund_name
, fund_code
, expenditures
from ucla_fundledger_vw
where (fund_code like '%FRT8' or fund_code like '%TAX9')
and fiscal_period_name >= '2017-2018'
order by fiscal_period_name, ledger_name, fundline
;
