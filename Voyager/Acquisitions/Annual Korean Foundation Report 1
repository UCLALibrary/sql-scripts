select DISTINCT
 -- f.ledger_name
 -- f.fund_name
--l, f.fund_code
--, ilif.percentage
--, ilif.amount/100 -- use this
--, ucladb.toBaseCurrency(ilif.amount, i.currency_code, i.conversion_rate) as usd_amount
--, ili.line_price -- don't use this
--, i.invoice_number
--, i.voucher_number
--, i.currency_code
--, i.conversion_rate
  vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.imprint) AS imprint
, vger_support.unifix(bt.series) AS series
, f.fund_code


from ucla_fundledger_vw f

inner join invoice_line_item_funds ilif
  on f.ledger_id = ilif.ledger_id
  and f.fund_id = ilif.fund_id
inner join invoice_line_item ili on ilif.inv_line_item_id = ili.inv_line_item_id
inner join line_item li on ili.line_item_id = li.line_item_id
inner join ucla_bibtext_vw bt on li.bib_id = bt.bib_id
inner join invoice i on ili.invoice_id = i.invoice_id
inner join invoice_status ist on i.invoice_status = ist.invoice_status
where f.fiscal_period_name = '2014-2015'
--and f.fund_type like 'Gift%'
--and f.fund_category = 'Reporting'
and f.fund_code = 'C3SPEAKF92'
