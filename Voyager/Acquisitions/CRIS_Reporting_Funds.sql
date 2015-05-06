/*  List of CRIS reporting funds, for ledger restructuring project.
    VBT-386
*/
select
  fund_id
, institution_fund_id as fau
, fund_name
, fund_code as old_fund_code
, '' as new_fund_code
from ucla_fundledger_vw
where fiscal_period_name = '2014-2015'
and ledger_name = 'CRIS 14-15'
and fund_category = 'Reporting'
order by fundline
;