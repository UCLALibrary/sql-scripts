/*  Find intra-SRLF monographic duplicate items.
    Counts are sufficient for now.
    For Peter Broadwell and Tin Tran.
    JIRA: RR-101
    
    Run as vger_report to create working tables for large datasets.
*/

create table vger_report.tmp_srlf_mono_items as
select
  bm.bib_id
, bm.mfhd_id
, mi.item_id
, mi.item_enum
, ib.item_barcode
, it.item_type_name
, bi.normal_heading as oclc
from ucladb.bib_text bt
inner join ucladb.bib_index bi on bt.bib_id = bi.bib_id
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join ucladb.item_barcode ib on mi.item_id = ib.item_id
inner join ucladb.item i on mi.item_id = i.item_id
inner join ucladb.item_type it on i.item_type_id = it.item_type_id
where bt.bib_format = 'am'
and bi.index_code = '0350'
and bi.normal_heading like 'UCOCLC%'
and l.location_code = 'sr'
and ib.barcode_status = 1 --Active
;

create index vger_report.ix_oclc on vger_report.tmp_srlf_mono_items (oclc);

select count(*) from vger_report.tmp_srlf_mono_items;
-- 3362412 2015-08-20 

-- Multi-vol dups (enumeration is present)
select
  normal_heading
, item_enum
, count(*) as items
from vger_report.tmp_srlf_mono_items
where item_enum is not null
group by normal_heading, item_enum
having count(*) = 2
;
-- 1 set of 5
-- 33 sets of 4
-- 458 sets of 3
-- 7535 sets of 2

with d as (
  select
    oclc
  , item_enum
  from vger_report.tmp_srlf_mono_items
  where item_enum is not null
  group by oclc, item_enum
  having count(*) > 1
)
select
  i.oclc
, i.bib_id
, i.mfhd_id
, i.item_enum
, i.item_barcode
, i.item_type_name
, vger_support.unifix(bt.title_brief) as title
from vger_report.tmp_srlf_mono_items i
inner join ucladb.bib_text bt on i.bib_id = bt.bib_id
where (oclc, item_enum) in (select oclc, item_enum from d)
order by oclc, bib_id, item_enum, item_barcode
;


-- Single-vol dups (same OCLC but no enumeration)
with d as (
  select
    oclc
  , count(*) as items
  from vger_report.tmp_srlf_mono_items
  where item_enum is null
  group by oclc
  having count(*) > 1
)
select items, count(*) as sets
from d
group by items
order by items
;

with d as (
  select
    oclc
  , count(*) as items
  from vger_report.tmp_srlf_mono_items
  where item_enum is null
  group by oclc
  having count(*) > 1
)
select items, count(*) as sets, items*count(*) as total
from d
group by items
order by items
;

-- 34 dups in one set?
select oclc, count(*) as items
from vger_report.tmp_srlf_mono_items
where item_enum is null
group by oclc
having count(*) > 20
;

with d as (
  select
    oclc
  from vger_report.tmp_srlf_mono_items
  where item_enum is null
  group by oclc
  having count(*) > 1
)
select
  i.oclc
, i.bib_id
, i.mfhd_id
, i.item_barcode
, i.item_type_name
, vger_support.unifix(bt.title_brief) as title
from vger_report.tmp_srlf_mono_items i
inner join ucladb.bib_text bt on i.bib_id = bt.bib_id
where oclc in (select oclc from d)
order by oclc, bib_id, item_barcode
;


-- no oclc
create table vger_report.tmp_srlf_mono_items_no_oclc as
select
  bm.bib_id
, bm.mfhd_id
, mi.item_id
, mi.item_enum
, bt.network_number
, bt.isbn
, bt.lccn
from ucladb.bib_text bt
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
where bt.bib_format = 'am'
and l.location_code = 'sr'
and not exists (
  select * 
  from ucladb.bib_index
  where index_code = '0350'
  and normal_heading like 'UCOCLC%'
  and bib_id = bt.bib_id
)
;

select count(distinct bib_id) as bibs
from vger_report.tmp_srlf_mono_items_no_oclc
where network_number is null
and isbn is null
and lccn is null
;

select count(distinct bib_id) as bibs, count(*) as items from vger_report.tmp_srlf_mono_items_no_oclc;
-- 8206, 16538

select count(distinct bib_id) as bibs, count(*) as items from vger_report.tmp_srlf_mono_items;
-- 2882688,	3362412

drop table vger_report.tmp_srlf_mono_items purge;
drop table vger_report.tmp_srlf_mono_items_no_oclc purge;
