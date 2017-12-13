WITH circ_trans AS
(
	SELECT
		ib.item_barcode,
		mm.normalized_call_no,
		substr(mm.normalized_call_no,1,3) AS call_no_start,
		l.location_display_name,
                                          l.location_name,
		vger_support.charges_from_date(i.item_id,to_date(#prompt('STARTDATE1')#, 'YYYY-MM-DD')) AS charges,
		vger_support.renewals_from_date(i.item_id,to_date(#prompt('STARTDATE1')#, 'YYYY-MM-DD')) AS renewals
	FROM
		ucladb.item i
		INNER JOIN ucladb.item_barcode ib ON i.item_id = ib.item_id
		INNER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
		INNER JOIN ucladb.mfhd_master mm ON mi.mfhd_id = mm.mfhd_id
		INNER JOIN ucladb.location l ON i.perm_location = l.location_id
	where
		l.location_code LIKE (#prompt('LOCALE1')# || '%')
)
SELECT
	call_no_start,
	location_display_name,
                     location_name,
	sum(charges) AS charges,
	sum(renewals) AS renewals
FROM
	circ_trans
GROUP BY
	call_no_start,
	location_display_name,
                     location_name
HAVING
	sum(charges) > 0 OR sum(renewals) > 0
ORDER BY
	call_no_start,
	location_display_name

SELECT location_code,location_name FROM vger_support.circ_by_call_locales
