/*  Duplicate vendors, based on code.
    SILSLA-43.
*/

with dups as (
  select *
  from vendor
  where normal_vendor_code in (
    select normal_vendor_code from vendor group by normal_vendor_code having count(*) > 1
  )
)
select
  v.vendor_id
, v.vendor_code
, v.vendor_name
, v.institution_id
, v.create_date
, case when exists (select * from ucladb.po_vendor_history where vendor_id = v.vendor_id) then 'Y' else null end as has_hist
, case when exists (select * from ucladb.purchase_order where vendor_id = v.vendor_id) then 'Y' else null end as has_po
, case when exists (select * from ucladb.invoice where vendor_id = v.vendor_id) then 'Y' else null end as has_inv

from dups v
order by normal_vendor_code
;