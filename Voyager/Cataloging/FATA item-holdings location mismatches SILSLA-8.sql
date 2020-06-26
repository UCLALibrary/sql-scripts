/*  FATA items with permanent locations not matching the holdings.
    SILSLA-8
*/

select
  mm.mfhd_id
, l.location_code as mfhd_loc
, l2.location_code as item_loc
--, (select location_code from filmntvdb.location where location_id = i.temp_location) as temp_loc -- not used
, i.item_id
, ib.item_barcode
, mi.item_enum
from filmntvdb.item i
inner join filmntvdb.mfhd_item mi on i.item_id = mi.item_id
inner join filmntvdb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join filmntvdb.location l on mm.location_id = l.location_id
inner join filmntvdb.location l2 on i.perm_location = l2.location_id
left outer join filmntvdb.item_barcode ib on i.item_id = ib.item_id
where i.perm_location != mm.location_id
order by mi.mfhd_id, mi.item_id
;

