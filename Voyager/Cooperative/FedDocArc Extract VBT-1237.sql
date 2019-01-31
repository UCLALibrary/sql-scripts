/*  Identify US Federal Document records for FedDocArc project.
    Need same holdings/item data as Google/Hathi extract.
    VBT-1237
*/

select
  bt.bib_id
, ib.item_barcode
, ib.item_id
, l.location_code
, mm.display_call_no as call_number
, mi.item_enum
from ucladb.item i
inner join ucladb.item_barcode ib 
  on i.item_id = ib.item_id
  and ib.barcode_status = 1 --Active
inner join ucladb.mfhd_item mi on ib.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
where bt.bib_format in ('am', 'as') --LDR/06-07
and bt.place_code like '__u' --008/17
and substr(bt.field_008, 29, 1) = 'f' --008/28
-- Exclude Special collections - lots of locs
and l.location_code not in ('arsc', 'arscrr')
and l.location_code not like 'bihi%'
and l.location_code not like 'bisc%'
and l.location_code not like 'mggr%'
and l.location_code not like 'musc%'
and l.location_code not like 'scsc%'
and l.location_code not like 'sgsc%'
and l.location_code not in ('smsctallm', 'uaref')
and l.location_code not like 'yrsp%'
-- Exclude EAL
and l.location_code not like 'ea%'
-- Exclude Law, for now at least
and l.location_code not like 'lw%'
-- Exclude patron-driven records
and l.location_code not in ('pdacq')
-- Exclude the "affiliate" libraries
and substr(l.location_code, 1, 2) not in ('aa', 'ai', 'ca', 'ck', 'cs', 'er', 'id', 'il', 'lg', 'mi', 'ue')
-- Exclude microforms
and (lower(l.location_display_name) not like '%micr%' and lower(l.location_name) not like '%micr%')
-- Exclude SRLF?
and l.location_code not like 'sr%'
and ib.item_barcode is null
order by bt.bib_id, i.item_sequence_number
;
-- 388761 items 20190129, including srlf; 52885 without srlf
-- 20190130: Extracted 52,880 non-SRLF records for UClA; 220,831 SRLF records