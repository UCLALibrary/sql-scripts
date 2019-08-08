Enter file contents here
select
  f.fund_code
, bt.bib_id
, vger_support.unifix(nvl2(bt.author, bt.author || ' / ' || bt.title_brief, bt.title_brief)) as main_entry
, po.po_number
, v.vendor_name
, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) as usd_amt
, i.invoice_status_date as paid_date
, vger_support.get_fiscal_period(i.invoice_status_date) as fiscal_year
from ucladb.purchase_order po
inner join ucladb.vendor v on po.vendor_id = v.vendor_id
inner join ucladb.po_status pos on po.po_status = pos.po_status
inner join ucladb.line_item li on po.po_id = li.po_id
inner join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
inner join location l on lics.location_id = l.location_id
inner join ucladb.line_item_funds lif on lics.copy_id = lif.copy_id
inner join ucladb.fund f on lif.ledger_id = f.ledger_id and lif.fund_id = f.fund_id
inner join ucladb.bib_text bt on li.bib_id = bt.bib_id
left outer join ucladb.invoice_line_item ili on li.line_item_id = ili.line_item_id
left outer join ucladb.invoice i on ili.invoice_id = i.invoice_id
left outer join ucladb.invoice_status ist on i.invoice_status = ist.invoice_status
--where substr(f.fund_code, 3, 1) = 'S'
--and f.category = 2 -- Reporting
WHERE
       (f.fund_code = 'L3MPBIGE-1'
         or f.fund_code = 'L3SPBIGE-4'
         or f.fund_code = 'L3DEBIGE-2'
         OR f.fund_code = 'L3DEBIGE-1'
         OR f.fund_code = 'L3SCBIGE-1'
         OR f.fund_code = 'L3SEBIGE-1'
         OR f.fund_code = 'L3SPBIGE-1')

and pos.po_status_desc in ('Approved/Sent', 'Pending', 'Received Partial')

--and pos.po_status_desc in ('Approved/Sent', 'Pending', 'Received Partial')
-- Paid this FY or the previous 2, or never paid (left joins to invoice tables)
 and nvl(i.invoice_status_date, sysdate) >= add_months(vger_support.lws_utility.prev_fiscal_yr_start(sysdate), -12)
     and i.invoice_status_date >= add_months(vger_support.lws_utility.prev_fiscal_yr_start(sysdate), -12)
    -- and i.invoice_status_date is null)




order by  fund_code, vger_support.get_fiscal_period(i.invoice_status_date), main_entry, paid_date
