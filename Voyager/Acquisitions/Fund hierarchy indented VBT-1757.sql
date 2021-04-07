/*  Indented hierarchy of funds
    VBT-1757
*/
select 
  ledger_name
, fund_category
-- fundline is padded in 25-char segments, up to 7 deep; convert to 0-6 and create 4-char indents for each segment
, lpad('->  ', 4*((length(fundline)/25)-1), '->  ') || fund_name as fund_name
, fund_code
, institution_fund_id as fau
from ucla_fundledger_vw
where fiscal_period_name = '2020-2021'
order by ledger_name, fundline
;
