SELECT DISTINCT
--institution_fund_id,
ufv.ledger_name,
ufv.fund_name,
ufv.fund_code,
ufv.institution_fund_id,
ufv.current_allocation,
ufv.commitments,
ufv.expenditures,
ufv.expend_pending,
ufv.cash_balance,
ufv.free_balance

FROM UCLA_FUNDLEDGER_VW  ufv
 INNER JOIN INVOICE_FUNDS inf ON ufv.LEDGER_ID = inf.LEDGER_ID
 INNER JOIN INVOICE i ON inf.INVOICE_ID = i.INVOICE_ID

--WHERE UCLA_FUNDLEDGER_VW.FUND_category = 'Allocated'
WHERE    ufv.ledger_name LIKE 'SPEC%FOUNDATION 17-18'
      OR ufv.ledger_name LIKE 'SPEC%REGENTAL 17-18'
      AND i.invoice_update_date BETWEEN to_date('2017-07-01', 'YYYY-MM-DD') and to_date('2018-03-30', 'YYYY-MM-DD')

ORDER BY ufv.ledger_name
