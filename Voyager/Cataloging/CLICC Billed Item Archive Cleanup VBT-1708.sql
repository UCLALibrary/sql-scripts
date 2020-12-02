/*  CLICC Billed Item Archive cleanup.
    VBT-1708.
*/

-- Leftover items which could not be deleted
-- Similar queries found the items/mfhds which were deleted.
with holdings as (
  select record_id as mfhd_id
  from vger_subfields.ucladb_mfhd_subfield ms
  where ms.tag = '852h'
  and ms.subfield like 'Billed Item Archive%'
)
select distinct
  h.mfhd_id
, l.location_code
, mi.item_id
, ib.item_barcode
, (select ucladb.toBaseCurrency(sum(fine_fee_balance)) from fine_fee where item_id = mi.item_id) as fines
, vger_support.get_all_item_status(mi.item_id) as item_status
from holdings h
inner join mfhd_master mm on h.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
left outer join mfhd_item mi on h.mfhd_id = mi.mfhd_id
left outer join item_barcode ib on mi.item_id = ib.item_id and ib.barcode_status = 1 --Active
where l.location_code like 'cc%'
order by mi.item_id
;

