SELECT
	v.vendor_code,
	f.fiscal_period_name,
	f.ledger_name,
	f.fund_code,
	bm.mfhd_id,
	bm.bib_id,
	bt.bib_format as bib_level,
	bt.begin_pub_date as date1,
	bt.pub_place,
	bt.language,
	vger_support.get_bib_tags(bt.bib_id, '035') as f035,
	ucladb.GetBibTag(bt.bib_id, '050') as f050,
	vger_support.unifix(bt.title) as title,
	vger_support.get_bib_tags(bt.bib_id, '245') as f245,
	vger_support.unifix(ucladb.GetTag(bt.bib_id, 'B', '650', 1)) as f650_1,
	vger_support.unifix(ucladb.GetTag(bt.bib_id, 'B', '650', 2)) as f650_2,
	vger_support.get_bib_tags(bt.bib_id, '852b') as f852b,
	vger_support.get_bib_tags(bt.bib_id, '852h') as f852h,
	ib.item_barcode as barcode,
	it.reserve_charges as reserves,
	it.historical_charges as charges,
	it.historical_browses as browses,
	it.recalls_placed as recalls,
	it.holds_placed as holds,
	it.historical_bookings as bookings,
	it.short_loan_charges as short_loans,
	( 
		select coalesce(sum(reserve_charges), 0)
		from ucladb.reserve_item_history
		where item_id = it.item_id
	) as hist_reserves
FROM
	ucladb.invoice i
	inner join ucladb.vendor v on i.vendor_id = v.vendor_id
	inner join ucladb.invoice_line_item ili on i.invoice_id = ili.invoice_id
	inner join ucladb.invoice_line_item_funds ilif on ili.inv_line_item_id = ilif.inv_line_item_id
	inner join ucladb.ucla_fundledger_vw f on ilif.ledger_id = f.ledger_id and ilif.fund_id = f.fund_id
	inner join ucladb.line_item_copy_status lics on ilif.copy_id = lics.copy_id
	inner join ucladb.line_item li on ili.line_item_id = li.line_item_id -- slight shortcut but no data loss for 2004-2005 at least
	left outer join ucladb.bib_mfhd bm on lics.mfhd_id = bm.mfhd_id
	left outer join ucladb.bib_text bt on bm.bib_id = bt.bib_id
	left outer join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
	left outer join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
	left outer join ucladb.item it on mi.item_id = it.item_id
	left outer join ucladb.item_barcode ib on it.item_id = ib.item_id and ib.barcode_status = 1 -- Approved
WHERE
	substr(bt.bib_format, 2, 1) = 'm' -- bib level
	AND i.invoice_status = 1 --approved invoices
	AND $X{IN, v.vendor_id, select_vendor} --Jasper version of v.vendor_id IN (x,y,z)
	AND $X{IN, f.ledger_id, ledger_name_multi} --Jasper version of f.ledger_id IN (x,y,z)
	AND $X{IN, f.fiscal_period_id, fiscal_year_multi} --Jasper version of f.fiscal_period_id IN (x,y,z)
ORDER BY 
	vendor_code, 
	bib_id, 
	mfhd_id
