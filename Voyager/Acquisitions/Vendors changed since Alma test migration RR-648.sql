/*  Find apparent updates to vendors, and their supporting data.
    for updating Alma vendors since these migrated in December.
    Collect vendor_id from several relevant tables.
    RR-648
*/

with vendors as (
-- 67
select vendor_id from vendor
where create_date >= to_date('2020-12-04', 'YYYY-MM-DD')
or update_date >= to_date('2020-12-04', 'YYYY-MM-DD')
UNION
-- 0
select vendor_id from vendor_account
where status_date >= to_date('2020-12-04', 'YYYY-MM-DD')
UNION
-- 81 address, 17 more with phone - 61 distinct vendor_id
select 
  va.vendor_id 
from vendor_address va
left outer join vendor_phone vp on va.address_id = vp.address_id
where va.modify_date >= to_date('2020-12-04', 'YYYY-MM-DD')
or vp.modify_date >= to_date('2020-12-04', 'YYYY-MM-DD')
) 
-- Total is still 67 distinct
select 
  v.vendor_code
, v.vendor_name
, vt.vendor_type_desc as vendor_type
, v.default_currency
, v.federal_tax_id
, v.institution_id
, v.create_date
, v.update_date
from vendors vs
inner join vendor v on vs.vendor_id = v.vendor_id
inner join vendor_types vt on v.vendor_type = vt.vendor_type
where v.create_date >= to_date('2020-12-04', 'YYYY-MM-DD')
or v.update_date >= to_date('2020-12-04', 'YYYY-MM-DD')
order by vendor_code
;

desc vendor_account; 
-- no date info except status_date
desc vendor_note; 
-- no date info
desc vendor_address;
-- modify_date
desc vendor_phone; 
-- modify_date
desc vendor; -- create_date, update_date
