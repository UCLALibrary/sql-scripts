-- Work as vger_support to create (semi)permanent archival tables

-- Items with statistical category ZZZ (ZZZ: SYSU TRANSFER ONLY)
-- Create initial table with column definitions from Voyager tables
-- ONE TIME ONLY - DO NOT DROP/CREATE ONCE TESTING IS DONE
/*
-- Boxes
drop table  vger_support.powell_zzz_boxes purge;
create table vger_support.powell_zzz_boxes (
  box_number int not null primary key
, packing_date date
, item_count int
)
;

-- Items
drop table vger_support.powell_zzz_items purge;
create table vger_support.powell_zzz_items as
select
  i.item_id
, (select location_code from ucladb.location where location_id = i.perm_location) as item_perm_loc
, (select location_code from ucladb.location where location_id = i.temp_location) as item_temp_loc
, ib.item_barcode
, i.copy_number
, mi.item_enum
, mm.mfhd_id
, l.location_code as mfhd_loc
, mm.normalized_call_no
, mm.display_call_no
, bt.bib_id
, bt.isbn
, ( select replace(normal_heading, 'UCOCLC', '')
    from ucladb.bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
  ) as oclc
, unifix(bt.author) as author
, unifix(bt.title_brief) as title_brief
, unifix(bt.imprint) as imprint
, ist.date_applied as status_date
from ucladb.item i
inner join ucladb.item_stats ist on i.item_id = ist.item_id
inner join ucladb.item_stat_code isc on ist.item_stat_id = isc.item_stat_id
inner join ucladb.item_barcode ib on i.item_id = ib.item_id
inner join ucladb.mfhd_item mi on i.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
-- no data, just empty table
where 1=0
;

-- Add non-Voyager columns for this project
alter table vger_support.powell_zzz_items
add project_status varchar2(30)
;

alter table vger_support.powell_zzz_items
add box_number int references vger_support.powell_zzz_boxes (box_number)
;

-- Indexes
create index vger_support.ix_powell_zzz_item_id on vger_support.powell_zzz_items (item_id);

-- Make sure the BatchCat program can access the data
grant select on vger_support.powell_zzz_items to ucla_preaddb;

*/

-- Add data from Voyager: same as initial query,
-- but only add items which have ZZZ category and 
-- are not already in the table.
insert into vger_support.powell_zzz_items
select
  i.item_id
, (select location_code from ucladb.location where location_id = i.perm_location) as item_perm_loc
, (select location_code from ucladb.location where location_id = i.temp_location) as item_temp_loc
, ib.item_barcode
, i.copy_number
, mi.item_enum
, mm.mfhd_id
, l.location_code as mfhd_loc
, mm.normalized_call_no
, mm.display_call_no
, bt.bib_id
, bt.isbn
, ( select replace(normal_heading, 'UCOCLC', '')
    from ucladb.bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
  ) as oclc
, unifix(bt.author) as author
, unifix(bt.title_brief) as title_brief
, ist.date_applied as status_date
, 'Pulled' as project_status
, null as box_number
, unifix(bt.imprint) as imprint
from ucladb.item i
inner join ucladb.item_stats ist on i.item_id = ist.item_id
inner join ucladb.item_stat_code isc on ist.item_stat_id = isc.item_stat_id
inner join ucladb.item_barcode ib on i.item_id = ib.item_id
inner join ucladb.mfhd_item mi on i.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
where isc.item_stat_code = 'ZZZ'
and ib.barcode_status = 1 -- Active
and not exists (
  select * from vger_support.powell_zzz_items
  where item_id = i.item_id
)
;

-- Series of checks for exceptions.  Any exceptions will prevent deletion, until they're reviewed / cleared.

-- First: Reset previous errors to 'Pulled' status as they may have been fixed.
update vger_support.powell_zzz_items
set 
  project_status = 'Pulled'
, status_date = sysdate
where project_status like 'ERROR%'
;

-- Item no longer has ZZZ code assigned - returned to stacks, remove from project
delete
from vger_support.powell_zzz_items z
where project_status not in ('Deleted', 'Packed')
and exists (
  select * from ucladb.item
  where item_id = z.item_id
)
and not exists (
  select * from ucladb.item i
  inner join ucladb.item_stats ist on i.item_id = ist.item_id
  inner join ucladb.item_stat_code isc on ist.item_stat_id = isc.item_stat_id
  where i.item_id = z.item_id
  and isc.item_stat_code = 'ZZZ'
)
;

-- Non-College location:
update vger_support.powell_zzz_items
set 
  project_status = 'ERROR: Not College item'
, status_date = sysdate
where item_perm_loc not like 'cl%'
or mfhd_loc not like 'cl%'
;

-- Currently charged out
update vger_support.powell_zzz_items z
set 
  project_status = 'ERROR: Charged out'
, status_date = sysdate
where project_status = 'Pulled'
and exists (
  select * from ucladb.circ_transactions where item_id = z.item_id
)
;

-- Has an active fine/fee
update vger_support.powell_zzz_items z
set 
  project_status = 'ERROR: Active fine'
, status_date = sysdate
where project_status = 'Pulled'
and exists (
  select * from ucladb.fine_fee where item_id = z.item_id and fine_fee_balance <> 0
)
;

-- On Reserve
update vger_support.powell_zzz_items z
set 
  project_status = 'ERROR: On Reserve'
, status_date = sysdate
where project_status = 'Pulled'
and exists (
  select * from ucladb.reserve_list_items where item_id = z.item_id
)
;

-- No other unsuppressed holdings
update vger_support.powell_zzz_items z
set 
  project_status = 'ERROR: No other holdings'
, status_date = sysdate
where project_status = 'Pulled'
and not exists (
  select *
  from ucladb.bib_mfhd bm
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  where bm.bib_id = z.bib_id
  and bm.mfhd_id <> z.mfhd_id
  and mm.suppress_in_opac = 'N'
)
;

-- Item has been deleted (presumably via the BatchCat program...)
update vger_support.powell_zzz_items z
set
  project_status = 'Deleted'
, status_date = sysdate
where not exists (
  select *
  from ucladb.item
  where item_id = z.item_id
)
and project_status not in ('Deleted', 'Packed')
;

-- Apply all of the status changes
commit;

select project_status, count(*) as num from vger_support.powell_zzz_items group by project_status order by project_status;

-- select count(*) from vger_support.powell_zzz_items;
-- select * from vger_support.powell_zzz_items where project_status not in ('Pulled', 'Deleted');
-- select * from vger_support.powell_zzz_items where project_status = 'Pulled' order by bib_id, mfhd_id, item_id;


-- Cleanup for box-testing
/*
select * from vger_support.powell_zzz_items where box_number is not null;
update vger_support.powell_zzz_items set project_status = 'Deleted', box_number = null where box_number is not null;
select * from vger_support.powell_zzz_boxes;
delete from vger_support.powell_zzz_boxes;
commit;
*/

/*
-- HOW TO HANDLE THESE???
Error deleting HolID 7008744 : Line item attached
-- and many more
*/

