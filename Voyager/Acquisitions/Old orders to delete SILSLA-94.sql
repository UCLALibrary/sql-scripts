/*  Old closed POs
    SILSLA-94
*/

-- Create working table as we need to refer to this data several times, before and after deletion
drop table vger_report.old_pos_delete purge;
create table vger_report.old_pos_delete as
select 
  -- Needed for PO deletion
  po.po_id
, po.po_number
-- Other data for checking
, li.bib_id
, lics.mfhd_id
, l.location_code
, bt.bib_format
, mm.call_no_type
, mm.display_call_no
, vger_support.get_oclc_number(li.bib_id) as oclc
from ucladb.purchase_order po
inner join ucladb.po_status pos on po.po_status = pos.po_status
inner join ucladb.po_type pot on po.po_type = pot.po_type
inner join ucladb.line_item li on po.po_id = li.po_id
inner join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
inner join ucladb.mfhd_master mm on lics.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.bib_text bt on li.bib_id = bt.bib_id
where pos.po_status_desc in ('Received Complete', 'Complete')
and pot.po_type_desc in ('Approval', 'Firm Order')
and po.po_status_date < to_date('2015-07-01', 'YYYY-MM-DD')
-- No invoice lines for any po line on this order
and not exists (
  select * from ucladb.invoice_line_item
  where line_item_id in (select line_item_id from ucladb.line_item where po_id = po.po_id)
)
;

select count(*), count(distinct po_id) from vger_report.old_pos_delete;
--579381 total rows, 196529 distinct POs, before filtering on location
-- Loc filter will remove 2712 and 945

create index vger_report.old_pos_delete_ix on vger_report.old_pos_delete (po_id);

-- POs to delete
with d as (
select distinct po_id, po_number from vger_report.old_pos_delete
minus
select distinct po_id, po_number from vger_report.old_pos_delete
where location_code in ('in', 'yrsshacq')
) select * from d inner join ucladb.purchase_order po on d.po_id = po.po_id
;
-- 195584 distinct POs to delete


