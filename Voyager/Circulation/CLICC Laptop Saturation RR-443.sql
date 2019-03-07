/*  Laptop/device usage by date range, focusing on simultaneous uses.
    Uses 15-minute sample windows, which can be adjusted in 
   
    Uses several WITH blocks for derived tables; see comments before each for details.
   
    RR-443
*/

-- Items with barcodes starting CBK (Chromebook) and MBP (MacBook Pro); item type not used consistently for these variations.
with items as (
  select
    ib.item_id
  , ib.item_barcode
  , substr(ib.item_barcode, 1, 3) as prefix
  , mi.item_enum
  , it.item_type_name
  , l.location_code
  , l.location_name
  from item_barcode ib
  inner join item i on ib.item_id = i.item_id
  inner join mfhd_item mi on i.item_id = mi.item_id
  inner join location l on i.perm_location = l.location_id
  inner join item_type it on i.item_type_id = it.item_type_id
  where (ib.item_barcode like 'CBK%' or ib.item_barcode like 'MBP%')
  and ib.barcode_status = 1 --Active
)
-- Number of relevant items in each location, per item permanent location
, counts as (
  select 
    prefix
  , location_name
  , count(*) as pieces
  from items
  group by prefix, location_name
)
-- Times within a date range; 15 minute duration assumed, adjust as needed by changing "15" below, in *two* places (the SELECT, and the CONNECT BY).
-- 1440 is minutes/day (24 * 60).
-- Adjust start_date and end_date as needed.
-- end_date is day *after* report ends (e.g., 20190215 is not included, report goes through 20190214).
, sample_times as (
  select
    (start_date + (level - 1) * 15/1440) as sample_time
  from (
    select 
      to_date('20190129', 'YYYYMMDD') as start_date
    , to_date('20190215', 'YYYYMMDD') as end_date
    from dual
  )
connect by (start_date + (level - 1) * 15/1440) < end_date
)
-- Circ transactions for the items above.
-- Only checks archive, for discharged items, not circ_transactions for current ones, since laptops have short loans.
-- Dates in WHERE clause must match dates in sample_times block above.
, transactions as (
  select
    i.location_name
  , i.prefix
  , cta.charge_date
  , cta.discharge_date
  , (select pieces from counts where location_name = i.location_name and prefix = i.prefix) as total_pieces
  from items i
  left outer join circ_trans_archive cta on i.item_id = cta.item_id
  where cta.charge_date between to_date('20190129', 'YYYYMMDD') and to_date('20190215', 'YYYYMMDD')
)
-- Finally, pull all the data together, counting the number of charge transactions which were active
-- at each sample_time.
select
  t.location_name
, t.prefix
, st.sample_time
, count(*) as charged_out
, t.total_pieces
from transactions t
inner join sample_times st on st.sample_time between t.charge_date and t.discharge_date
group by t.location_name, t.prefix, st.sample_time, t.total_pieces
order by location_name, prefix, sample_time
;

