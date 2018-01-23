SELECT 
	#prompt('REPORTDAY')# AS report_day, 
	vger_support.single_day_nonreserve_renewals(#prompt('REPORTDAY')#) AS nonreserve_renewals,
	vger_support.single_day_nonreserve_charges(#prompt('REPORTDAY')#) AS nonreserve_charges,
	vger_support.single_day_reserve_charges(#prompt('REPORTDAY')#) AS reserve_charges,
	vger_support.single_day_reserve_renewals(#prompt('REPORTDAY')#) AS reserve_renewals,
        vger_support.single_day_patron_count(#prompt('REPORTDAY')#) AS patrons_on_snapshot,
        (SELECT COUNT(patron_id) FROM ucladb.patron WHERE TRUNC(EXPIRE_DATE) >= TRUNC(SYSDATE)) AS all_unexpired_patrons,
        (SELECT COUNT(pb.patron_barcode_id) FROM ucladb.patron_barcode pb INNER JOIN ucladb.patron p ON pb.patron_id = p.patron_id WHERE pb.barcode_status = 1 AND p.expire_date >= SYSDATE) AS cards_for_active_patrons,
        (SELECT COUNT(patron_barcode_id) FROM ucladb.patron_barcode WHERE barcode_status = 1) AS active_library_cards
FROM 
	dual
