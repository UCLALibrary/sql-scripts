SELECT
ledger_name,
FUND_NAME,
--ORIGINAL_ALLOCATION,
CURRENT_ALLOCATION,
EXPENDITURES,
EXPEND_PENDING,
COMMITMENTS,
--COMMIT_PENDING,
CASH_BALANCE,
free_balance,
--free_balance - commit_pending AS FreeBalMINUSComPen,
CASE current_allocation
        WHEN 0 THEN 0
        ELSE (expend_pending+expenditures) / current_allocation * 100 END
        AS Percentage_Spent

FROM (

SELECT
ledger_name,
FUND_NAME,
ORIGINAL_ALLOCATION,
CURRENT_ALLOCATION,
EXPENDITURES,
EXPEND_PENDING,
COMMITMENTS,
COMMIT_PENDING,
CASH_BALANCE,
free_balance,
free_balance - commit_pending AS FreeBalMINUSComPen,
CASE current_allocation
        WHEN 0 THEN 0
        ELSE (expend_pending+expenditures) / current_allocation * 100 END
        AS Percentage_Spent,

1 AS sorter

FROM FUNDLEDGER_VW

WHERE FISCAL_PERIOD_NAME = '2018-2019'

AND (ledger_name = 'ARTS 18-19'
 OR ledger_name = 'BIOMED 18-19'
 --OR ledger_name = 'GENERAL ACQUISITIONS 18-19'
 OR ledger_name = 'CRIS 18-19'
 OR ledger_name = 'POWELL 18-19'
 OR ledger_name = 'EAST ASIAN 18-19'
 OR ledger_name = 'HSS 18-19'
 OR ledger_name = 'IS 18-19'
 OR ledger_name = 'MANAGEMENT 18-19'
 OR ledger_name = 'MUSIC 18-19'
 OR ledger_name = 'SSH 18-19'
 OR ledger_name = 'SEL 18-19'
 OR ledger_name = 'SPECIAL COLLECTIONS 18-19'
 --OR ledger_name = 'SSHA ACQUISITIONS 18-19'
 OR ledger_name = 'COLLECTION MANAGEMENT 18-19')

 AND FUND_CATEGORY = 'Summary'
 AND FUND_name = 'Ledger Summary'


UNION ALL

SELECT
ledger_name,
FUND_NAME,
ORIGINAL_ALLOCATION,
CURRENT_ALLOCATION,
EXPENDITURES,
EXPEND_PENDING,
COMMITMENTS,
COMMIT_PENDING,
CASH_BALANCE,
free_balance,
free_balance - fundledger_vw.commit_pending AS FreeBalMINUSComPen,
CASE current_allocation
        WHEN 0 THEN 0
        ELSE (FUNDLEDGER_VW.expend_pending+FUNDLEDGER_VW.expenditures) / FUNDLEDGER_VW.current_allocation * 100 END
        AS Percentage_Spent,


3 AS sorter

FROM FUNDLEDGER_VW

WHERE FUNDLEDGER_VW.FISCAL_PERIOD_NAME = '2018-2019'



 AND   (FUNDLEDGER_VW.fund_name Like 'AUL Patron Driven Acq%'
    OR  FUNDLEDGER_VW.fund_name like 'AUL PDA Digital%'
    OR  FUNDLEDGER_VW.fund_name LIKE 'YRL Grad Reserves%'
    OR  FUNDLEDGER_VW.fund_name = 'Shared Approvals'
    OR  FUNDLEDGER_VW.fund_name LIKE 'AUL ACMI%OER%')

    AND FUNDLEDGER_VW.FUND_CATEGORY = 'Allocated'

UNION ALL

SELECT
FUNDLEDGER_VW.ledger_name,
FUNDLEDGER_VW.FUND_NAME,
FUNDLEDGER_VW.ORIGINAL_ALLOCATION,
FUNDLEDGER_VW.CURRENT_ALLOCATION,
FUNDLEDGER_VW.EXPENDITURES,
FUNDLEDGER_VW.EXPEND_PENDING,
FUNDLEDGER_VW.COMMITMENTS,
FUNDLEDGER_VW.COMMIT_PENDING,
FUNDLEDGER_VW.CASH_BALANCE,
fundledger_vw.free_balance,
fundledger_vw.free_balance - fundledger_vw.commit_pending AS FreeBalMINUSComPen,
CASE current_allocation
        WHEN 0 THEN 0
        ELSE (FUNDLEDGER_VW.expend_pending+FUNDLEDGER_VW.expenditures) / FUNDLEDGER_VW.current_allocation * 100 END
        AS Percentage_Spent,

2 AS sorter


FROM FUNDLEDGER_VW

WHERE FUNDLEDGER_VW.FISCAL_PERIOD_NAME = '2018-2019'
    --AND FUNDLEDGER_VW.ledger_name = 'AUL COLLECTIONS 18-19'

 AND
    (FUNDLEDGER_VW.fund_name Like 'AUL Discretionary%'
  OR FUNDLEDGER_VW.fund_name Like 'Barter Exchange%'
  Or FUNDLEDGER_VW.fund_name Like 'Bindery%'
  Or FUNDLEDGER_VW.fund_name LIKE 'AUL CDL Resources%'
  Or FUNDLEDGER_VW.fund_name LIKE 'Collection Mgmt Support%'
  Or FUNDLEDGER_VW.fund_name = 'Digitalization'
  Or FUNDLEDGER_VW.fund_name LIKE 'Preservation%'

  OR  FUNDLEDGER_VW.fund_name LIKE 'ILL%')

  AND FUNDLEDGER_VW.FUND_CATEGORY = 'Summary'


) temp

ORDER BY sorter, ledger_name
