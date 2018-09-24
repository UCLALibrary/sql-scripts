/*  Total serial expenditures (per fund codes) in 2017-2018.
    RR-393
*/

-- For total serials/databases spend: Total of all transactions in FY18 where the fund code contains 'S' or ‘D’ in the 3rd position. 
select
  ucladb.setCurrencyDecimals(sum(ifs.expenditures), 'USD') as usd_total
from ucla_fundledger_vw f
inner join invoice_funds ifs on f.ledger_id = ifs.ledger_id and f.fund_id = ifs.fund_id
where f.fiscal_period_name = '2017-2018'
and substr(f.fund_code, 3, 1) in ('S', 'D')
;
-- 6940244.95 S only; 11513888.35 S & D

-- For total print serials spend: Total of all transactions in FY18 where the fund code contains 'S' in the 3rd position 
-- AND the 4th position contains value 'A', 'C', 'F', 'H', 'L', 'M', 'N', 'P', 'S', 'T',  'V', or [hyphen] 
select
  ucladb.setCurrencyDecimals(sum(ifs.expenditures), 'USD') as usd_total
from ucla_fundledger_vw f
inner join invoice_funds ifs on f.ledger_id = ifs.ledger_id and f.fund_id = ifs.fund_id
where f.fiscal_period_name = '2017-2018'
and substr(f.fund_code, 3, 1) = 'S'
and substr(f.fund_code, 4, 1) in ('A', 'C', 'F', 'H', 'L', 'M', 'N', 'P', 'S', 'T',  'V', '-')
;
-- 1217194.77

-- For total electronic serials spend: Deduce this subtotal by subtracting total print serials spend from total serials spend.
select 6940244.95 - 1217194.77 as diff from dual;
-- 5723050.18
