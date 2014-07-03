-- Electronic monographs (e-books) for ARL stats
-- Apparently no longer needed, since 2008/2009
-- See ARL_E-books.sql for current queries used for "E-Books" sheet in annual Excel file, same as
-- for "Number of Electronic Books Held": https://docs.library.ucla.edu/x/ugDc

-- MAKE SURE THESE ARE CORRECT!

-- e-books purchased: possibly needed 2008/2009+
define FY_START = '20080701 000000';
define FY_END   = '20090630 235959';

with ebooks as (
  select
    bm.bib_id
  , bm.mfhd_id
  from ucladb.bib_text bt
  inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join ucladb.location l on mm.location_id = l.location_id
  where bt.bib_format = 'am'
  and l.location_code = 'in'
)
select
  e.bib_id
, e.mfhd_id
, ili.piece_identifier
, po.po_number
, pos.po_status_desc
, pot.po_type_desc
from ebooks e
inner join ucladb.line_item_copy_status lics on e.mfhd_id = lics.mfhd_id
inner join ucladb.line_item li on lics.line_item_id = li.line_item_id
inner join ucladb.purchase_order po on li.po_id = po.po_id
inner join ucladb.po_status pos on po.po_status = pos.po_status
inner join ucladb.po_type pot on po.po_type = pot.po_type
inner join ucladb.invoice_line_item ili on lics.line_item_id = ili.line_item_id
inner join ucladb.invoice i on ili.invoice_id = i.invoice_id
inner join ucladb.invoice_status ist on i.invoice_status = ist.invoice_status
where i.invoice_status_date between To_Date('&FY_START', 'YYYYMMDD HH24MISS') and To_Date('&FY_END', 'YYYYMMDD HH24MISS')
and ist.invoice_status_desc = 'Approved'
;