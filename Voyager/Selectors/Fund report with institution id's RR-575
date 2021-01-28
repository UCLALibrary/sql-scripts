--USE this AK good
select distinct
--f.fund_category,
f.ledger_name,
f.fund_name,
f.institution_fund_id,
--f.original_allocation,
f.current_allocation,
f.expenditures,
f.cash_balance,
f.commitments,
f.free_balance



from ucla_fundledger_vw f
inner join invoice_line_item_funds ilif
  on f.ledger_id = ilif.ledger_id
  and f.fund_id = ilif.fund_id
inner join invoice_line_item ili on ilif.inv_line_item_id = ili.inv_line_item_id
inner join line_item li on ili.line_item_id = li.line_item_id
--inner join bib_text bt on li.bib_id = bt.bib_id
inner join invoice i on ili.invoice_id = i.invoice_id
inner join invoice_status ist on i.invoice_status = ist.invoice_status

where f.fiscal_period_name = '2020-2021'
      and f.fund_category = 'Reporting'
      and i.invoice_status_date BETWEEN to_date('20201201', 'YYYYMMDD') AND to_date('20201231', 'YYYYMMDD')
      
    and (f.institution_fund_id like '%603510%'
     or f.institution_fund_id like '%603512%'
     or f.institution_fund_id like '%603513%'
     or f.institution_fund_id like '%603520%'
     or f.institution_fund_id like '%603300%')
     
     
     order by f.ledger_name, f.institution_fund_id
--and ist.invoice_status_desc = 'Approved'



