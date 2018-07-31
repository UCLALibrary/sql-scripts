/*  Inventory list of bipam location
    RR-377
*/

select
  l.location_code
, case
    when exists (
      select *
      from bib_mfhd bm2
      inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
      inner join location l2 on mm2.location_id = l.location_id
      where bm2.bib_id = bt.bib_id
      and l.location_code like 'sr%'
    ) then 'Y'
    else 'N'
  end as srlf_has
, ib.item_barcode
, vger_support.Get_All_Item_Status(ib.item_id) as item_status
, mm.normalized_call_no
, mm.display_call_no as call_number
, bt.bib_id
, ( select replace(normal_heading, 'UCOCLC', '') 
    from bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
  ) as oclc
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.series) as series
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join item_barcode ib on mi.item_id = ib.item_id  and ib.barcode_status = 1 --Active
where l.location_code = 'bipam'
order by mm.normalized_call_no, bt.bib_id
;

