/*  Report on map counts.
    Unfortunately, most holdings in map locations don't have item records, so tried two approaches.
    RR-333
*/

-- Item based: item type = 'map', necessary for YRL stacks locations but probably wrong for map locations.
select
  l.location_code
, it.item_type_display
, count(*) as num
from location l
inner join item i on l.location_id = i.perm_location
inner join item_type it on i.item_type_id = it.item_type_id
where l.location_code in ('sgput', 'sgputmaps', 'yralmapt', 'yrmapat', 'yrmapc', 'yrmaphmpc', 'yrmaphtlc', 'yrmaphvfc', 'yrmapstx', 'yr', 'yr*', 'yr**', 'yr***', 'yrrisrr')
and it.item_type_code = 'map'
group by l.location_code, it.item_type_display
order by l.location_code, it.item_type_display
;

-- Holdings based: more accurate for map locations though not necessarily a correlation between holdings count and items count - one holdings could have any number of maps, with no item records.
-- Format data for Jira table 
with d as (
select
  l.location_code
, count(distinct mm.mfhd_id) as holdings
, count(distinct mi.item_id) as items
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
where l.location_code in ('sgput', 'sgputmaps', 'yralmapt', 'yrmapat', 'yrmapc', 'yrmaphmpc', 'yrmaphtlc', 'yrmaphvfc', 'yrmapstx')--, 'yr', 'yr*', 'yr**', 'yr***', 'yrrisrr')
group by l.location_code
order by l.location_code
)
select '| ' || location_code || ' | ' || holdings || ' | ' || items || ' |'
from d
order by location_code
;