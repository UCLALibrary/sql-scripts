/*  Amounts paid on selected funds, per LBS request.
    RR-331
*/

select 
  f.ledger_name
, f.fund_name
, f.fund_code
, f.institution_fund_id
, i.invoice_number
, ucladb.setCurrencyDecimals(sum(ifs.expenditures), 'USD') as usd_amount_paid -- invoice_funds table is always USD
from ucla_fundledger_vw f
left outer join invoice_funds ifs on f.ledger_id = ifs.ledger_id and f.fund_id = ifs.fund_id
left outer join invoice i on ifs.invoice_id = i.invoice_id
where f.fiscal_period_name = '2017-2018' -- CHANGE THIS as needed
and f.fund_category = 'Reporting'
and regexp_like(f.fund_code, '^.[23].E.+$')
group by f.ledger_name, f.fund_name, f.fund_code, f.institution_fund_id, i.invoice_number
order by f.ledger_name, f.fund_name, usd_amount_paid
;