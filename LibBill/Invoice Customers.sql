SELECT
	up.normal_last_name || ', ' || up.normal_first_name AS patron_name,
	up.email,
	ivw.invoice_number,
	ivw.created_date AS invoice_date
FROM
	vger_support.ucladb_patrons up
	INNER JOIN invoice_owner.invoice_vw ivw ON up.patron_id = ivw.patron_id
WHERE
	trunc(ivw.created_date) BETWEEN trunc(to_date(#prompt('Date_1')#, 'YYYY-MM-DD')) AND trunc(to_date(#prompt('Date_2')#, 'YYYY-MM-DD'))
	AND substr(invoice_number, 1, 2) IN (#promptmany('Unit_Code')#)
	AND status IN (#promptmany('Invoice_status')#)
ORDER BY
	patron_name,
	invoice_date DESC

