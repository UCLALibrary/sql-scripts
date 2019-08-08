WITH unpaid AS (
	SELECT
		ff.patron_id,
		ff.fine_fee_balance
	FROM
		ucladb.fine_fee ff 
	WHERE
		ff.fine_fee_balance > 0
)
SELECT
	vger_support.get_latest_barcode(u.patron_id) AS patron_barcode,
	normal_last_name || ', ' || normal_first_name AS patron_name,
	vger_support.test_get_latest_patron_group(u.patron_id) AS patron_group_display,
	sum(u.fine_fee_balance)/100 AS fine_fee_balance
FROM
	unpaid u
	INNER JOIN ucladb.patron p ON u.patron_id = p.patron_id
GROUP BY
	vger_support.get_latest_barcode(u.patron_id),
	normal_last_name || ', ' || normal_first_name,
	vger_support.test_get_latest_patron_group(u.patron_id)
ORDER BY
	patron_barcode
;
