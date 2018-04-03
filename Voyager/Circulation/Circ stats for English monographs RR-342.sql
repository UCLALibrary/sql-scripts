/*  Circ stats for English language monographs from specific vendors on specific ledgers.
    RR-342
*/

--with d as (
select 
  v.vendor_code
, pot.po_type_desc as po_type
, f.fiscal_period_name
--, f.ledger_name
, f.fund_code
, ucladb.toBaseCurrency(ilif.amount, i.currency_code, i.conversion_rate) as usd_amount
, bm.mfhd_id
, bm.bib_id
, substr(bt.bib_format, 2, 1) as bib_level
, bt.begin_pub_date as date1
, bt.place_code
, bt.language
, ( select replace(normal_heading, 'UCOCLC', '')
    from bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
) as oclc
, ucladb.GetBibTag(bt.bib_id, '050') as f050
, vger_support.unifix(bt.title) as title
, vger_support.unifix(ucladb.GetTag(bt.bib_id, 'B', '650', 1)) as f650_1
, vger_support.unifix(ucladb.GetTag(bt.bib_id, 'B', '650', 2)) as f650_2
, l.location_code
, ucladb.GetMfhdSubfield(mm.mfhd_id, '852', 'h') as f852h
, mi.item_enum
, ib.item_barcode as barcode
, i.recalls_placed as recalls
, i.holds_placed as holds
, i.historical_charges as charges
, i.historical_browses as browses
, i.historical_bookings as bookings -- uniformly 0, we don't use Media Booking module
, i.reserve_charges as reserves -- this is only non-zero for items currently on reserve, which have been charged while on reserve
, i.short_loan_charges as short_loans -- uniformly 0, we don't use short loans
-- Historical reserves data - for items no longer on reserve
, ( select coalesce(sum(reserve_charges), 0)
    from reserve_item_history
    where item_id = i.item_id
) as hist_reserves
from invoice i
inner join invoice_status ist on i.invoice_status = ist.invoice_status
inner join vendor v on i.vendor_id = v.vendor_id
inner join invoice_line_item ili on i.invoice_id = ili.invoice_id
inner join invoice_line_item_funds ilif on ili.inv_line_item_id = ilif.inv_line_item_id
inner join ucla_fundledger_vw f on ilif.ledger_id = f.ledger_id and ilif.fund_id = f.fund_id
inner join line_item_copy_status lics on ilif.copy_id = lics.copy_id
inner join line_item li on ili.line_item_id = li.line_item_id -- slight shortcut but no data loss for 2004-2005 at least
inner join purchase_order po on li.po_id = po.po_id
inner join po_type pot on po.po_type = pot.po_type
-- Is everything still linked on these old orders?
-- 2004-2005: 14319 rows, 1 null mfhd
left outer join bib_mfhd bm on lics.mfhd_id = bm.mfhd_id
left outer join bib_text bt on bm.bib_id = bt.bib_id
left outer join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
left outer join location l on mm.location_id = l.location_id
left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join item i on mi.item_id = i.item_id
left outer join item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 -- Approved
where ist.invoice_status_desc = 'Approved'
and v.vendor_code in ('YBP', 'YBPUK', 'LFD', 'ASU', 'CHD', 'CHD1', 'COU', 'COUNIJ', 'HEN')
and f.ledger_name in ('SSHA CRIS 04-05', 'SSHA CRIS Approval Plans 04-05', 'SSHA CRIS SP 04-05')
and substr(bt.bib_format, 2, 1) = 'm' -- bib level
--and bm.mfhd_id is null
order by vendor_code, bib_id, mfhd_id, item_enum
--) select count(*) from d
;
-- 18376 of 20329 are eng for 2004-2005
select * from ledger where fiscal_year_id = 1 order by ledger_name;


select * from reserve_item_history where sysdate between effect_date and expire_date;
select * from item where short_loan_charges > 0;
select * from invoice_line_item_funds;
select * from line_item_copy_status where mfhd_id = 6943303;
select count(*) from line_item_copy_status where item_id is null;