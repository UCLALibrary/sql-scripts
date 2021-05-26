/*  Old canceled print POs
    SILSLA-100
*/

-- Create working table as we need to refer to this data several times, before and after deletion
drop table vger_report.tmp_canceled_pos purge;
create table vger_report.tmp_canceled_pos as
select 
  -- Needed for PO deletion
  po.po_id
, po.po_number
-- Other data for this project
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
where pos.po_status_desc = 'Canceled'
and pot.po_type_desc in ('Approval', 'Firm Order')
and po.po_status_date < to_date('2015-07-01', 'YYYY-MM-DD')
-- No invoice lines for any po line on this order
and not exists (
  select * from ucladb.invoice_line_item
  where line_item_id in (select line_item_id from ucladb.line_item where po_id = po.po_id)
)
;
select count(distinct po_id), count(*) from vger_report.tmp_canceled_pos;
-- 11768 distinct POs, 13164 rows
grant select on vger_report.tmp_canceled_pos to ucla_preaddb;

-- Data for PO deletion
select distinct
  po_id
, po_number
from vger_report.tmp_canceled_pos
-- Removes 4535 rows, 3662 POs from deletion
where po_id not in (
  select po_id from vger_report.tmp_canceled_pos
  where substr(bib_format, 2, 1) in ('i', 's')
  or location_code in ('in', 'yrsshacq')
)
order by po_id
;
--8106 distinct POs for deletion

-- Holdings and possibly bibs to delete
select distinct
  po.bib_id
, mm.mfhd_id
from vger_report.tmp_canceled_pos po
-- Found problems with PO copies linked to no-longer-extant mfhds?
inner join ucladb.mfhd_master mm on po.mfhd_id = mm.mfhd_id
-- The 8107 deleted POs
where po_id in (
  select distinct
    po_id
  from vger_report.tmp_canceled_pos
  -- Removes 4535 rows, 3662 POs from deletion
  where po_id not in (
    select po_id from vger_report.tmp_canceled_pos
    where substr(bib_format, 2, 1) in ('i', 's')
    or location_code in ('in', 'yrsshacq')
  )
)
and not exists (select * from ucladb.mfhd_item where mfhd_id = po.mfhd_id)
and ( 
        not exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = po.mfhd_id and tag = '852h')
    or  exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = po.mfhd_id and tag = '852h' and upper(subfield) like '%SUPPRESS%')
)
--5969 potential holdings/bibs for deletion; 5536 distinct bib/mfhd pairs
order by po.bib_id, mm.mfhd_id
;

-- What's left?
select count(distinct po_id)
from vger_report.tmp_canceled_pos po
inner join ucladb.bib_mfhd bm on po.bib_id = bm.bib_id and po.mfhd_id = bm.mfhd_id
where substr(bib_format, 2, 1) not in ('i', 's')
and location_code not in ('in', 'yrsshacq')
;
--2492

-- Get OCLC numbers for deleted bibs
--- ***** RUN THIS BEFORE DELETION, or incorporate into table above before deletion *****
drop table vger_report.tmp_ids purge;
create table vger_report.tmp_ids (
  bib_id int not null
)
;
create index vger_report.tmp_ids_ix on vger_report.tmp_ids (bib_id);
select count(*) from vger_report.tmp_ids;

select bib_id, vger_support.get_oclc_number(bib_id) from vger_report.tmp_ids order by bib_id;

select distinct
  bib_id, oclc
from vger_report.tmp_canceled_pos po
where not exists (select * from ucladb.bib_master where bib_id = po.bib_id)
order by po.bib_id
;
-- 3853

--Deleted: 3853 bibs, 4244 hols