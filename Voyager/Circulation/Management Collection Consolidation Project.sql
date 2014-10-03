-- Work as vger_support to create (semi)permanent archival tables
-- MANAGEMENT versions of Powell tables
-- Items with statistical category ZMG (ZMG: MGMT SYSU TRANSFER)
-- Create initial table for Management project based on Powell
-- ONE TIME ONLY - DO NOT DROP/CREATE ONCE TESTING IS DONE

/*
-- Boxes
drop table vger_support.mgmt_zmg_boxes purge;
create table vger_support.mgmt_zmg_boxes (
  box_number int not null primary key
, packing_date date
, item_count int
)
;

-- Items
drop table vger_support.mgmt_zmg_items purge;
create table vger_support.mgmt_zmg_items as
select * from vger_support.powell_zzz_items 
where 1=0;

alter table vger_support.mgmt_zmg_items
add constraint  fk_mgmt_box_number foreign key (box_number) references vger_support.mgmt_zmg_boxes (box_number)
;

-- Indexes
create index vger_support.ix_mgmt_zmg_item_id on vger_support.mgmt_zmg_items (item_id);

-- Make sure the BatchCat program can access the data
grant select on vger_support.mgmt_zmg_items to ucla_preaddb;
*/

-- ONE-TIME data from deleted items, for Management
-- 2181 mg items deleted 7/24 - 8/4 (inclusive)
-- Not all of these may be relevant to the ZMG project but no way to tell post-deletion... but if they don't get packed, they don't matter.
/*
insert into vger_support.mgmt_zmg_items
select
  d.item_id
, d.location_code as item_perm_loc
, null as item_temp_loc
, d.item_barcode
, d.copy_number
, d.item_enum
, d.mfhd_id
, d.location_code as mfhd_loc
, mm.normalized_call_no
, mm.display_call_no
, d.bib_id
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
, d.delete_datetime as status_date
, 'Deleted' as project_status
, null as box_number
, unifix(bt.imprint) as imprint
from vger_subfields.ucladb_deleted_items d
inner join ucladb.mfhd_master mm on d.mfhd_id = mm.mfhd_id
inner join ucladb.bib_text bt on d.bib_id = bt.bib_id
where d.delete_datetime between to_date('20140724', 'YYYYMMDD') and to_date('20140805', 'YYYYMMDD')
and d.location_code like 'mg%'
;
commit;
*/


-- Add data from Voyager: same as initial query,
-- but only add items which have ZMG category and 
-- are not already in the table.
insert into vger_support.mgmt_zmg_items
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
where isc.item_stat_code = 'ZMG'
and ib.barcode_status = 1 -- Active
and not exists (
  select * from vger_support.mgmt_zmg_items
  where item_id = i.item_id
)
;

-- Series of checks for exceptions.  Any exceptions will prevent deletion, until they're reviewed / cleared.

-- First: Reset previous errors to 'Pulled' status as they may have been fixed.
update vger_support.mgmt_zmg_items
set 
  project_status = 'Pulled'
, status_date = sysdate
where project_status like 'ERROR%'
;

-- Non-Management location:
update vger_support.mgmt_zmg_items
set 
  project_status = 'ERROR: Not Management item'
, status_date = sysdate
where item_perm_loc not like 'mg%'
or mfhd_loc not like 'mg%'
;

-- Currently charged out
update vger_support.mgmt_zmg_items z
set 
  project_status = 'ERROR: Charged out'
, status_date = sysdate
where exists (
  select * from ucladb.circ_transactions where item_id = z.item_id
)
;

-- Has an active fine/fee
update vger_support.mgmt_zmg_items z
set 
  project_status = 'ERROR: Active fine'
, status_date = sysdate
where exists (
  select * from ucladb.fine_fee where item_id = z.item_id and fine_fee_balance <> 0
)
;

-- On Reserve
update vger_support.mgmt_zmg_items z
set 
  project_status = 'ERROR: On Reserve'
, status_date = sysdate
where exists (
  select * from ucladb.reserve_list_items where item_id = z.item_id
)
;

/* NOT RELEVANT FOR MANAGEMENT
-- No other unsuppressed holdings
update vger_support.mgmt_zmg_items z
set 
  project_status = 'ERROR: No other holdings'
, status_date = sysdate
where not exists (
  select *
  from ucladb.bib_mfhd bm
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  where bm.bib_id = z.bib_id
  and bm.mfhd_id <> z.mfhd_id
  and mm.suppress_in_opac = 'N'
)
;
*/

-- Item has been deleted (presumably via the BatchCat program...)
update vger_support.mgmt_zmg_items z
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

select count(*) from vger_support.mgmt_zmg_items;
select * from vger_support.mgmt_zmg_items where project_status not in ('Pulled', 'Deleted');

-- select * from vger_support.mgmt_zmg_items where project_status = 'Pulled' order by bib_id, mfhd_id, item_id;

select project_status, count(*) as num from vger_support.mgmt_zmg_items group by project_status order by project_status;

-- Cleanup for box-testing
/*
select * from vger_support.mgmt_zmg_items where box_number is not null;
update vger_support.mgmt_zmg_items set project_status = 'Deleted', box_number = null where box_number is not null;
select * from vger_support.mgmt_zmg_boxes;
delete from vger_support.mgmt_zmg_boxes;
commit;
*/

/*
-- HOW TO HANDLE THESE???
*/

