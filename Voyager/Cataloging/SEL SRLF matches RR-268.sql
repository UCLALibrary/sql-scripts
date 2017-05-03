/*  Check a selected set of SEL barcodes against SRLF, looking for items where SRLF's copy is building use or non-circ.
    RR-268
*/

-- Data imported from Excel file
create index vger_report.ix_tmp_sel_barcodes_bib on vger_report.tmp_sel_barcodes (bib_id);
create index vger_report.ix_tmp_sel_barcodes_bar on vger_report.tmp_sel_barcodes (sel_barcode);

select *
from vger_report.tmp_sel_barcodes sb
where not exists (
  select *
  --from ucladb.item_barcode
  --where item_barcode = sb.sel_barcode
  from ucladb.bib_text
  where bib_id = sb.bib_id
)
;
-- 4647: all bibs exist, all barcodes exist, all rows distinct.  Update 2017-05-02: L0064030463	on bib 2231002 no longer exists.

select distinct
  sb.sel_barcode
, sb.bib_id
, it.item_type_name
, l.location_code
, ib.item_barcode as srlf_barcode
, mi.item_enum as srlf_enum
from vger_report.tmp_sel_barcodes sb
inner join ucladb.bib_mfhd bm on sb.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join ucladb.item i on mi.item_id = i.item_id
inner join ucladb.item_type it on i.item_type_id = it.item_type_id
inner join ucladb.item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 -- Active
where l.location_code like 'sr%' -- = 'sr'
and it.item_type_name in ('Building Use', 'Non-circulating')
order by location_code, item_type_name, sel_barcode
;


-- clean up
-- drop table vger_report.tmp_sel_barcodes purge;