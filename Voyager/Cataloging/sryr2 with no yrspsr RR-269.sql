/*  Items on sryr2 holdings, where the same bib has no yrspsr holdings.
    Part of RR-269.
*/
with all_data as (
select
  l.location_code
, bm.bib_id
, bm.mfhd_id
, mm.call_no_type
, mm.display_call_no
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code in ('sryr2', 'yrspsr')
)
-- sryr2 holdings without yrspsr holdings on the same bib
, not_both as (
  select
    ad.*
  from all_data ad
  where not exists (
    select * from all_data
    where bib_id = ad.bib_id
    and location_code != ad.location_code
  )  
)
select 
  mi.item_id
, sr.mfhd_id
, sr.display_call_no
, vger_subfields.GetSubfields(mi.mfhd_id, '852z', 'mfhd', 'ucladb') as f852z
, vger_subfields.GetSubfields(mi.mfhd_id, '852x', 'mfhd', 'ucladb') as f852x
, GetMFHDTag(mi.mfhd_id, '901') as f901
, GetMFHDTag(mi.mfhd_id, '916') as f916
, ist.date_applied as deposit_date
, isc.item_stat_code_desc as deposit_library
from not_both sr
inner join mfhd_item mi on sr.mfhd_id = mi.mfhd_id
left outer join item_stats ist on mi.item_id = ist.item_id
left outer join item_stat_code isc on ist.item_stat_id = isc.item_stat_id
where sr.location_code = 'sryr2'
and (isc.item_stat_code between 'a' and 'z' or isc.item_stat_code is null)
order by sr.mfhd_id, mi.item_id
;
-- 23593 holdings; 23535 sryr2, 58 yrspsr
-- 40023 items for sryr2; 37 have no depositing library info
