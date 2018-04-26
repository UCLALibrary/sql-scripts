create table vger_report.tmp_gbs_import (
  bib_id int not null
, bib_level char(1)
, date_type char(1)
, date1 varchar2(4)
, date2 varchar2(4)
, pub_place varchar2(3)
, gov_doc char(1)
, gpo_item_no varchar2(100)
, sudoc_no varchar2(100)
, f099a varchar2(100)
, author nvarchar2(100) -- truncate these
, f245a nvarchar2(100) -- truncate these
, f245b nvarchar2(100) -- truncate these
, f26xa nvarchar2(100) -- truncate these
, f26xb nvarchar2(100) -- truncate these
, f26xc nvarchar2(100) -- truncate these
, loc_code varchar2(10)
, call_number varchar2(200)
, item_enum varchar2(100)
, item_barcode varchar2(20)
)
;
/*
  Imported all 559869 rows from UCLA 4/2018 list except for 1:
  Bib 6535150 has f245b longer than 2000 nchar which sqlldr can't handle, but
  it's for L0099884124 a biomed loc so no matter.
*/
grant select on vger_report.tmp_gbs_import to ucla_preaddb;
create index vger_report.ix_tmp_gbs_import on vger_report.tmp_gbs_import (item_barcode);
-- drop table vger_report.tmp_gbs_import purge;

-- Remove non-YRL items since we're only sending from YRL now
delete from vger_report.tmp_gbs_import where loc_code not like 'yr%';
-- 503418
commit;

select * --count(*) 
from vger_report.tmp_gbs_import g
where not exists (
  select * from ucladb.item_barcode
  where item_barcode = g.item_barcode
)
and NOT exists (
  select * from vger_subfields.ucladb_deleted_items 
  where item_barcode = g.item_barcode
)
;
-- 3018 not found by barcode; 2961 of those have been deleted
-- 57 unaccounted for?
-- Remove them all, since we can't easily match item-level data without matching barcodes
delete from vger_report.tmp_gbs_import g
where not exists (
  select * from ucladb.item_barcode
  where item_barcode = g.item_barcode
)
;
commit;

-- Remove 2920 items which are now in SRLF, and 2 more currently not in YRL
delete from vger_report.tmp_gbs_import g
where item_barcode in (
  select
    g.item_barcode
  from vger_report.tmp_gbs_import g
  inner join ucladb.item_barcode ib on g.item_barcode = ib.item_barcode
  inner join ucladb.mfhd_item mi on ib.item_id = mi.item_id
  inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
  inner join ucladb.location l on mm.location_id = l.location_id
  where g.loc_code != l.location_code
  and l.location_code not like 'yr%'
)
;
commit;

-- This leaves 50510 items in YRL to try to pull
select count(*) from vger_report.tmp_gbs_import;

-- Generate picklist, using *current* loc and item status
select 
  l.location_code as current_loc
, g.bib_id
, mm.display_call_no as current_call_no
--, g.call_number
, mi.item_enum as current_item_enum
--, g.item_enum
, g.item_barcode
, vger_support.get_all_item_status(ib.item_id) as item_status
, case when regexp_like(p.first_name, 'CART[0-9]{3}') then p.first_name else null end as gbs_cart
, g.date1
, g.date2
, g.author
, g.f245a as title
from vger_report.tmp_gbs_import g
inner join ucladb.item_barcode ib on g.item_barcode = ib.item_barcode
inner join ucladb.item i on ib.item_id = i.item_id
inner join ucladb.mfhd_item mi on i.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
left outer join ucladb.circ_transactions ct on ib.item_id = ct.item_id
left outer join ucladb.patron p on ct.patron_id = p.patron_id
-- Don't try to compare bib_id: complicates bound-withs, probably not relevant for those or serial title changes either
--inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
--inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
--where g.bib_id != bm.bib_id
-- 18 have call number mismatch for varying reasons
--where mm.display_call_no != g.call_number
-- Item enum often is different but seems to be just from better standardization/labeling
--where mi.item_enum != g.item_enum
order by l.location_code, mm.normalized_call_no, i.item_sequence_number
;

