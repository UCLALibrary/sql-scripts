/*  Stats for page and pickup.
    VBT-1711.

    Started Oct 12 2020.
*/

with requests as (
  select
    archive_id as call_slip_id
  , item_id
  , location_id
  , patron_id
  , patron_group_id
  , date_requested
  , status
  , status_date
  , no_fill_reason
  from call_slip_archive
  where date_requested >= to_date('20201012', 'YYYYMMDD')
  and print_group_id = 2 -- PANDP
  union all
  select
    call_slip_id
  , item_id
  , location_id
  , patron_id
  , patron_group_id
  , date_requested
  , status
  , status_date
  , no_fill_reason
  from call_slip
  where date_requested >= to_date('20201012', 'YYYYMMDD')
  and print_group_id = 2 -- PANDP
)
, charges as (
  select
    item_id
  , patron_id
  , charge_date
  from circ_transactions
  where item_id in (select distinct item_id from requests)
  union all
  select
    item_id
  , patron_id
  , charge_date
  from circ_trans_archive
  where item_id in (select distinct item_id from requests)
)
select
  r.call_slip_id
, r.item_id
, substr(l.location_code, 1, 2) as unit
, l.location_name
, r.patron_id
, pg.patron_group_name
, r.date_requested
, r.status_date
, st.status_desc as status
, nf.reason_desc as nf_reason
, case
    when exists (
      select * from charges
      where item_id = r.item_id
      and patron_id = r.patron_id
      and charge_date > r.date_requested
    )
    then 'Y'
    else null
end as borrowed
from requests r
inner join patron_group pg on r.patron_group_id = pg.patron_group_id
inner join call_slip_status_type st on r.status = st.status_type
inner join location l on r.location_id = l.location_id
left outer join no_fill_reason nf on r.no_fill_reason = nf.reason_id
where patron_id not in (8946, 8949) -- LSC and YRL ILL internal requests
order by call_slip_id
;




