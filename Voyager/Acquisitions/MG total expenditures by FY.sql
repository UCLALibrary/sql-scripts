select
  f.fund_code
, sum(inf.expenditures / 100) as expenditures
from ucla_fundledger_vw f
inner join invoice_funds inf on f.ledger_id = inf.ledger_id and f.fund_id = inf.fund_id
where f.ledger_name LIKE 'Contracts% 13-14'
and f.fund_category = 'Reporting'

         -- AND ist.invoice_status_desc = 'Approved'
          AND (
                ( (substr(f.fund_code, 3, 1) = 'S')
              OR (substr(f.fund_code, 3, 1) = 'M')
              OR (substr(f.fund_code, 3, 1) = 'D')  )

            -- AND ((substr(f.fund_code, 4, 1) = 'E')
            -- AND  (substr(f.fund_code, 4, 1) <> '-') )
              --    )

            AND (substr(f.fund_code, 4, 1) <> 'E') )
group by f.fund_code
order by f.fund_code
