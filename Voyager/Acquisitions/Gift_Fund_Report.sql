/*  Report on gift fund expenditures
    for Angela Allen.
    https://jira.library.ucla.edu/browse/RR-185
*/

select
  f.fund_type
, f.fund_code
, f.fund_name
, f.institution_fund_id
, ucladb.toBaseCurrency(ilif.amount, i.currency_code, i.conversion_rate) as usd_amount
, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) as usd_line_price
, ili.piece_identifier
, i.invoice_number
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.publisher) as publisher
, bt.publisher_date
from ucla_fundledger_vw f
inner join invoice_line_item_funds ilif 
  on f.ledger_id = ilif.ledger_id
  and f.fund_id = ilif.fund_id
inner join invoice_line_item ili
  on ilif.inv_line_item_id = ili.inv_line_item_id
inner join invoice i 
  on ili.invoice_id = i.invoice_id
inner join line_item li 
  on ili.line_item_id = li.line_item_id
inner join bib_text bt
  on li.bib_id = bt.bib_id
where f.fiscal_period_name = '2015-2016'
and f.fund_type in ('Gift Endowment Income', 'Gift Non-endowment')
and f.fund_category = 'Reporting'
order by fund_type, fund_code, invoice_number
;