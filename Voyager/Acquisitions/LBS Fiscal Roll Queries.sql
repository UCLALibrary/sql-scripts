-- Fund transactions by fiscal year
SELECT
	u.ledger_name
,	u.fund_name
,	u.fund_code
,	u.fund_category
,	u.institution_fund_id AS fau
,	tmp.trans_type_desc AS trans_type
,	tmp.reference_no
,	tmp.amount
FROM ucla_fundledger_vw u
INNER JOIN
(	SELECT
		ft.ledger_id
	,	CASE
			WHEN ft.statistical_fund IS NOT NULL THEN ft.statistical_fund
			ELSE ft.fund_id
		END AS fund_id
	,	ftt.trans_type_desc
	,	ft.reference_no
	,	Sum(ft.amount) / 100 AS amount
	FROM fund_transaction ft
	INNER JOIN vger_support.fund_transaction_type ftt
		ON ft.trans_type = ftt.trans_type
	GROUP BY
		ft.ledger_id
	,	CASE
			WHEN ft.statistical_fund IS NOT NULL THEN ft.statistical_fund
			ELSE ft.fund_id
		END
	,	ftt.trans_type_desc
	,	ft.reference_no
	HAVING Sum(amount) != 0
) tmp
	ON u.ledger_id = tmp.ledger_id
	AND u.fund_id = tmp.fund_id
WHERE u.fiscal_period_name = '2019-2020' -- PARAMETER
ORDER BY u.ledger_name, fau, trans_type
;

-- Fund Snapshot by Fiscal Year
SELECT
	ledger_name
,	fund_name
,	fund_code
,	fund_category
,	fau
,	original_allocation
,	current_allocation
,	commitments
,	commit_pending
,	expenditures
,	expend_pending
,	cash_balance
,	avail_balance
FROM
(	SELECT
		ledger_name
	,	fund_name
	,	fund_code
	,	fund_category
	,	institution_fund_id AS fau
	,	original_allocation
	,	current_allocation
	,	commitments
	,	commit_pending
	,	expenditures
	,	expend_pending
	,	cash_balance
	,	free_balance AS avail_balance
	,	RPad(vger_support.fundlineage_ucla(fund_id, ledger_id), 250, 'Z') AS fund_sort
	,	Decode(fund_category, 'Summary', 2, 'Allocated', 1, 'Reporting', 0) AS fund_type_sort
	FROM ucla_fundledger_vw
	WHERE fiscal_period_name = '2020-2021' -- PARAMETER
) t
ORDER BY ledger_name, fund_sort, fund_type_sort
;

-- Funds with Transaction Summaries by Fiscal Year
SELECT
	ledger_name
,	fund_name
,	fund_code
,	fund_category
,	fau
,	original_allocation
,	current_allocation
,	commitments
,	commit_pending
,	expenditures
,	expend_pending
,	cash_balance
,	avail_balance
,	ft_initial_allocation
,	ft_allocation_increase
,	ft_allocation_decrease
,	ft_commitments
,	ft_expenditures
,	ft_transfers_in
,	ft_transfers_out
FROM
(	SELECT
		u.ledger_name
	,	u.fund_name
	,	u.fund_code
	,	u.fund_category
	,	u.fund_type
	,	u.institution_fund_id AS fau
	,	u.original_allocation
	,	u.current_allocation
	,	u.cash_balance
	,	u.free_balance AS avail_balance
	,	u.commitments
	,	u.commit_pending
	,	u.expenditures
	,	u.expend_pending
	,	ft.initial_allocation AS ft_initial_allocation
	,	ft.allocation_increase AS ft_allocation_increase
	,	ft.allocation_decrease AS ft_allocation_decrease
	,	ft.commitments AS ft_commitments
	,	ft.expenditures AS ft_expenditures
	,	ft.transfers_in AS ft_transfers_in
	,	ft.transfers_out AS ft_transfers_out
	,	RPad(vger_support.fundlineage_ucla(u.fund_id, u.ledger_id), 250, 'Z') AS fund_sort
	,	Decode(u.fund_category, 'Summary', 2, 'Allocated', 1, 'Reporting', 0) AS fund_type_sort
	FROM ucla_fundledger_vw u
	LEFT OUTER JOIN
	(	SELECT
			ledger_id
		,	CASE
				WHEN statistical_fund IS NOT NULL THEN statistical_fund
				ELSE fund_id
			END AS fund_id
		,	Sum(CASE trans_type WHEN 1 THEN amount/100 ELSE 0 END) AS Initial_Allocation
		,	Sum(CASE trans_type WHEN 2 THEN amount/100 ELSE 0 END) AS Allocation_Increase
		,	Sum(CASE trans_type WHEN 3 THEN amount/100 ELSE 0 END) AS Allocation_Decrease
		,	Sum(CASE trans_type WHEN 4 THEN amount/100 ELSE 0 END) AS Commitments
		,	Sum(CASE trans_type WHEN 5 THEN amount/100 ELSE 0 END) AS Expenditures
		,	Sum(CASE trans_type WHEN 6 THEN amount/100 ELSE 0 END) AS Transfers_In
		,	Sum(CASE trans_type WHEN 7 THEN amount/100 ELSE 0 END) AS Transfers_Out
		FROM fund_transaction
		GROUP BY
			ledger_id
		,	CASE
				WHEN statistical_fund IS NOT NULL THEN statistical_fund
				ELSE fund_id
			END
	) ft
		ON u.ledger_id = ft.ledger_id
		AND u.fund_id = ft.fund_id
	WHERE u.fiscal_period_name = '2019-2020' -- PARAMETER
) t
ORDER BY ledger_name, fund_sort, fund_type_sort
;