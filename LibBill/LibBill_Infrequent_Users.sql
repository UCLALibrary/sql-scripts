/*  LibBill users who have not changed anything invoice-related in the last 90 days.
    RR-275
*/

with actions as (
  select 'invoice' as tab, created_date, created_by from invoice
  union all
  select 'invoice_adjustment' as tab, created_date, created_by from invoice_adjustment
  union all
  select 'invoice_note' as tab, created_date, created_by from invoice_note
  union all
  select 'line_item' as tab, created_date, created_by from line_item
  union all
  select 'line_item_adjustment' as tab, created_date, created_by from line_item_adjustment
  union all
  select 'line_item_note' as tab, created_date, created_by from line_item_note
  union all
  select 'payment' as tab, payment_date as created_date, created_by from payment -- this one is different
)
, users as (
  select
    su.last_name
  , su.first_name
  , su.user_name
  , su.user_role
  , su.create_date
  , ( select max(created_date) from actions where created_by = su.user_name) as most_recent
  from staff_user su
  where su.user_role is not null
  and su.user_role not in ('inactive')
)
select *
from users
where most_recent is null
or most_recent <= trunc(sysdate) - 90
order by last_name, first_name
;
-- 51 rows

