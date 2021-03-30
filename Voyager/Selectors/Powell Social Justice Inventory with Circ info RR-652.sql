/*  Detailed inventory list, with circ info, for Social Justice collection.
    RR-652
*/

select 
  bt.bib_id
, vger_support.get_oclc_number(bt.bib_id) as oclc
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, mm.display_call_no
, ( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from bib_location bl
    inner join location l2 on bl.location_id = l2.location_id
    where bl.bib_id = bt.bib_id
    and l2.location_code != l.location_code
) as other_locs
, case
    when exists (
        select *
        from bib_mfhd bm2
        inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
        inner join location l2 on mm2.location_id = l2.location_id
        where bm2.bib_id = bt.bib_id
        and l2.location_code like 'sr%'
      ) 
    then 'Y'
    else 'N'
  end as has_srlf
, case
    when i.perm_location != l.location_id
    then (select location_code from location where location_id = i.perm_location)
    else null
  end as item_loc
, ib.item_barcode as barcode
, mi.item_enum
, i.copy_number as copy
, i.create_date as item_created
, vger_support.get_all_item_status(i.item_id) as item_status
, ( (select count(*) from circ_trans_archive where item_id = i.item_id)
  + (select count(*) from circ_transactions where item_id = i.item_id)
) as charges
, (select max(discharge_date) from circ_trans_archive where item_id = i.item_id) as last_discharge
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join item i on mi.item_id = i.item_id
left outer join item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 --Active
where l.location_code = 'clsustain'
order by mm.normalized_call_no, copy_number
;
-- 377 rows total
-- 3 holdings have no items: bib ids 8201080, 7843410, 6457362
-- bib id 7593886 has dup(?) barcodes

