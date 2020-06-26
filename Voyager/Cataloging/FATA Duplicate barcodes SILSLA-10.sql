/*  FATA duplicate item barcodes.
    SILSLA-10
*/

-- Duplicates and counts
select
  item_barcode
, count(*) as items
from filmntvdb.item_barcode
group by item_barcode
having count(*) > 1
order by items desc, item_barcode
;

-- Total count of duplicates
select count(*)
from filmntvdb.item_barcode
where item_barcode in (
  select
    item_barcode
  from filmntvdb.item_barcode
  group by item_barcode
  having count(*) > 1
)
;

