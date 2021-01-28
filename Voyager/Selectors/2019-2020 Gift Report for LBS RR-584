select
  f.ledger_name
, f.fund_name
, f.fund_type
, f.institution_fund_id
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.publisher_date) as pub_date
, vger_support.unifix(bt.pub_dates_combined) as pub_dates_combined
--, ilif.amount -- use this
, ucladb.toBaseCurrency(ilif.amount, i.currency_code, i.conversion_rate) as line_price

from ucla_fundledger_vw f

inner join invoice_line_item_funds ilif
  on f.ledger_id = ilif.ledger_id
  and f.fund_id = ilif.fund_id
inner join invoice_line_item ili on ilif.inv_line_item_id = ili.inv_line_item_id
inner join line_item li on ili.line_item_id = li.line_item_id
inner join bib_text bt on li.bib_id = bt.bib_id
inner join invoice i on ili.invoice_id = i.invoice_id
inner join invoice_status ist on i.invoice_status = ist.invoice_status

where f.fiscal_period_name = '2019-2020'
and f.fund_type like 'Gift%'
and ist.invoice_status_desc = 'Approved'
