/*  List of all vendors, with additional info,
    to help with pre-migration vendor cleanup.
    RR-521
*/

with po_data as (
  select
    v.vendor_id
  , count(distinct po.po_id) as pos
  , count(distinct li.line_item_id) as po_lines
  , (select count(distinct po_id) from purchase_order where vendor_id = v.vendor_id and po_status = 0) as pending
  , (select count(distinct po_id) from purchase_order where vendor_id = v.vendor_id and po_status = 1) as approved
  , (select count(distinct po_id) from purchase_order where vendor_id = v.vendor_id and po_status = 3) as recvd_partl
  , (select count(distinct po_id) from purchase_order where vendor_id = v.vendor_id and po_status = 4) as recvd_compl
  , (select count(distinct po_id) from purchase_order where vendor_id = v.vendor_id and po_status = 5) as complete
  , (select count(distinct po_id) from purchase_order where vendor_id = v.vendor_id and po_status = 6) as canceled
  from vendor v
  left outer join purchase_order po on v.vendor_id = po.vendor_id
  left outer join line_item li on po.po_id = li.po_id
  group by v.vendor_id
), inv_data as (
  select
    v.vendor_id
  , sum(ucladb.toBaseCurrency(i.line_item_subtotal, i.currency_code, i.conversion_rate)) as usd_line_cost
  , max(i.invoice_date) as last_inv_date
  from vendor v
  left outer join invoice i on v.vendor_id = i.vendor_id
  group by v.vendor_id
)
select 
  v.vendor_name
, v.vendor_code
, vt.vendor_type_desc as vendor_type
, vn.note as vendor_note -- checked, we have no more than 1 note per vendor so this is OK
, po.pos
, po.po_lines
, inv.usd_line_cost as inv_line_cost
, to_char(inv.last_inv_date, 'YYYY-MM-DD') as last_inv_date
, po.pending
, po.approved
, po.recvd_partl
, po.recvd_compl
, po.complete
, po.canceled
from vendor v
inner join po_data po on v.vendor_id = po.vendor_id
inner join inv_data inv on v.vendor_id = inv.vendor_id
inner join vendor_types vt on v.vendor_type = vt.vendor_type
left outer join vendor_note vn on v.vendor_id = vn.vendor_id -- Not all vendors have notes
order by v.vendor_code
;
-- 10887 rows in vendor



