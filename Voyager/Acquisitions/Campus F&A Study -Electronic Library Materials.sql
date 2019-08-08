SELECT
ledger_name,
fund_name,
fund_code,
expenditures FROM ucla_fundledger_vw

WHERE fiscal_period_name = '2016-2017'
 AND  (SubStr (ucla_fundledger_vw.FUND_CODE, 4,1) = 'E')
 AND
(   (SubStr (ucla_fundledger_vw.FUND_CODE, 3,1) = 'D')
 OR (SubStr (ucla_fundledger_vw.FUND_CODE, 3,1) = 'M')
 OR (SubStr (ucla_fundledger_vw.FUND_CODE, 3,1) = 'S')
)

