/*	Lists of patrons owing various ranges of amounts, for email and print notifications of policy change
	Excludes patrons expired on or before 3/31/2006
	For Don Sloane
	2006-05-30 akohler
*/


SELECT
	p.patron_id
,	p.institution_id
,	(	SELECT patron_group_name
		FROM ucladb.patron_group
		WHERE patron_group_id =
		(	SELECT patron_group_id
			FROM ucladb.patron_barcode
			WHERE patron_id = p.patron_id
			AND barcode_status = 1 -- active
			AND ROWNUM < 2 -- just the "first" active patron group
		)
	) AS patron_group
,	Trim(Coalesce(Trim(p.first_name) || ' ', '') || Coalesce(Trim(p.middle_name) || ' ', '') || Trim(p.last_name)) AS full_name
--,	p.expire_date
,	(p.total_fees_due / 100) AS total_fees_due
,	(	SELECT address_line1
		FROM ucladb.patron_address
		WHERE patron_id = p.patron_id
		AND address_type = 3 -- email
		AND address_status != 'H' -- not "Hold mail"
		AND ROWNUM < 2 -- get just the "first" active email address
	) AS email_address
,	pa.address_line1
,	pa.address_line2
,	pa.address_line3
,	pa.address_line4
,	pa.address_line5
,	city
,	state_province
,	zip_postal
,	country
FROM ucladb.patron p
LEFT OUTER JOIN ucladb.patron_address pa ON p.patron_id = pa.patron_id
WHERE (p.expire_date IS NULL OR p.expire_date > To_Date('2006-03-31', 'YYYY-MM-DD'))
-- amounts in cents
--AND (p.total_fees_due >= 9000 AND p.total_fees_due < 10000)
AND (p.total_fees_due >= 10000 AND p.total_fees_due < 25000)
AND pa.address_type = 1 -- Permanent
ORDER BY Upper(email_address)
;
