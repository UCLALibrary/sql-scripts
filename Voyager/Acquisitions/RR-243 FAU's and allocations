SELECT
fund_code,
INSTITUTION_FUND_ID,
fund_name,
fund_category,
original_allocation,
current_allocation,
commitments,
commit_pending,
expenditures,
expend_pending,
cash_balance,
free_balance

--CASE current_allocation
  --      WHEN 0 THEN 000000
    --    ELSE (commitments+expenditures) / current_allocation * 100 END AS Percentage_Spent


FROM UCLA_FUNDLEDGER_VW
WHERE fund_category = 'Reporting' AND ledger_name = --'ARTS 16-17'
                                                  -- 'BIOMED 16-17'
                                                  --  'CRIS 16-17'
                                                 --   'MUSIC 16-17'
                                                 --   'POWELL 16-17'
                                                    'SEL 16-17'
      ORDER BY fund_name
