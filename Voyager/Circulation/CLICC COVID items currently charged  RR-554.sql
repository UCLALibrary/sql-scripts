/*  CLICC items currently charged out, charged after a certain date, with some contact info for follow-up.
    RR-554
*/
select distinct
  p.last_name
, p.first_name
, p.institution_id
, (select address_line1 from patron_address where patron_id = p.patron_id and address_type = 3 and rownum < 2) as email_address
--, pb.patron_barcode
--, pbs.barcode_status_desc as patron_barcode_status
, pg.patron_group_display as patron_group
, itp.item_type_display as item_type
, mi.item_enum
, ib.item_barcode
, ct.charge_date
, ct.charge_due_date
, l.location_name as circ_loc
from circ_transactions ct
inner join location l on ct.charge_location = l.location_id
inner join item i on ct.item_id = i.item_id
inner join mfhd_item mi on i.item_id = mi.item_id
inner join mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join location l2 on mm.location_id = l2.location_id
inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 --Active
inner join patron_barcode pb on ct.patron_id = pb.patron_id and ct.patron_group_id = pb.patron_group_id --and pb.barcode_status = 1 --Active
inner join patron_barcode_status pbs on pb.barcode_status = pbs.barcode_status_type
inner join patron p on ct.patron_id = p.patron_id
left outer join patron_group pg on pb.patron_group_id = pg.patron_group_id
where (l.location_name like 'CLICC%' or l2.location_name like 'CLICC%')
and ct.charge_date >= to_date('20200226 000000', 'YYYYMMDD HH24MISS')
--and item_type_display not like 'CLICC%'
order by p.last_name, p.first_name
;
--2086 rows as of 2020-05-13 13:43:26

