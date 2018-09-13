/*  Invoices paid on specific FAUs in 2018-2019
    * 4 603900 LM 56507 05 9200
    * 4 603900 LM 56507 05 6300
    * 4 603900 LM 56507 05 3002

    Could be parameterized for general report.
    RR-391
*/
select 
  f.fund_name
, f.institution_fund_id as fau
, f.fund_code
, ucladb.tobasecurrency(ili.line_price, i.currency_code, i.conversion_rate) as line_price_usd
, ili.piece_identifier
, i.invoice_update_date
, i.invoice_status_date
, bt.bib_id
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.publisher) as publisher
, coalesce(bt.publisher_date, bt.pub_dates_combined) as pub_date
from ucla_fundledger_vw f
inner join invoice_line_item_funds ilif on f.ledger_id = ilif.ledger_id and f.fund_id = ilif.fund_id
inner join invoice_line_item ili on ilif.inv_line_item_id = ili.inv_line_item_id
inner join line_item li on ili.line_item_id = li.line_item_id
inner join bib_text bt on li.bib_id = bt.bib_id
inner join invoice i on ili.invoice_id = i.invoice_id
where f.fiscal_period_name = '2018-2019'
and institution_fund_id like '%603900%LM%56507%'
order by f.fund_name, bt.author, bt.title
;
