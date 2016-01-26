with order_fund as (
  select
    po.po_id
  , po.po_number
  , po.currency_code
  , pot.po_type_desc
  , pos.po_status_desc
  , po.po_status_date
  , pof.commitments / 100.00 as commitments
--  , pof.commit_pending
--  , pof.expenditures
--  , pof.expend_pending
  , f.fiscal_period_name
  , f.fund_code
  , f.ledger_name
  , f.fund_name
  from purchase_order po
  inner join po_status pos on po.po_status = pos.po_status
  inner join po_type pot on po.po_type = pot.po_type
  inner join po_funds pof on po.po_id = pof.po_id
  inner join ucla_fundledger_vw f on pof.ledger_id = f.ledger_id and pof.fund_id = f.fund_id
  where pof.commitments != 0
  and pos.po_status_desc in ('Received Complete', 'Complete', 'Canceled')
  AND f.ledger_name LIKE '%12-13%'
)
, copies as (
  select
    ofd.po_id
  , lics.line_item_status
  , lics.invoice_item_status
  from order_fund ofd
  inner join line_item li on ofd.po_id = li.po_id
  inner join line_item_copy_status lics on li.line_item_id = lics.line_item_id
  where lics.invoice_item_status = 0
)
select *
from order_fund o
where exists (
  select *
  from copies
  where po_id = o.po_id
)
--and po_status_date >= to_date('2011-07-01', 'YYYY-MM-DD')
order by ledger_name, fund_code, po_status_date
 --fiscal_period_name,
