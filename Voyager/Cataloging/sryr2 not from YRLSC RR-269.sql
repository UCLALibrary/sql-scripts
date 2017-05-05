/*  Items on sryr2 holdings, where the items were not deposited by YRL SC (code yr2).
    Part of RR-269.
*/
with sryr2_non_yr2_items as (
  select 
    i.item_id
  , ist.date_applied as deposit_date
  , isc.item_stat_code_desc as deposit_library
  from location l
  inner join item i on l.location_id = i.perm_location
  left outer join item_stats ist on i.item_id = ist.item_id
  left outer join item_stat_code isc on ist.item_stat_id = isc.item_stat_id
  where l.location_code = 'sryr2'
  and (
        isc.item_stat_code is null 
    or  (isc.item_stat_code between 'a' and 'z' and isc.item_stat_code != 'yr2')
  )
)
select 
  s.item_id
, mm.mfhd_id
, mm.display_call_no
, vger_subfields.GetSubfields(mm.mfhd_id, '852z', 'mfhd', 'ucladb') as f852z
, vger_subfields.GetSubfields(mm.mfhd_id, '852x', 'mfhd', 'ucladb') as f852x
, GetMFHDTag(mm.mfhd_id, '901') as f901
, GetMFHDTag(mm.mfhd_id, '916') as f916
, s.deposit_date
, s.deposit_library
from sryr2_non_yr2_items s
inner join mfhd_item mi on s.item_id = mi.item_id
inner join mfhd_master mm on mi.mfhd_id = mm.mfhd_id
;
-- 25102 items

