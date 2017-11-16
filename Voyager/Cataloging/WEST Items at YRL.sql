/*  WEST items in YRL, for transfer to SRLF
    VBT-940
*/

with west as (
  select record_id as mfhd_id
  from vger_subfields.ucladb_mfhd_subfield
  where tag = '583f'
  and subfield = 'WEST'
)
select
  bt.bib_id
, mm.mfhd_id
, l.location_code
, mm.display_call_no as call_number
, mi.item_enum
, ib.item_barcode
, vger_support.get_all_item_status(i.item_id) as item_status
, bt.title_brief
from west w
inner join mfhd_master mm on w.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
-- Not all have items....
left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join item i on mi.item_id = i.item_id
left outer join item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 --Active
where l.location_code like 'yr%'
-- ... though all YRL materials apparently do have items
-- and mi.item_id is null
order by mm.normalized_call_no, i.item_sequence_number
;


