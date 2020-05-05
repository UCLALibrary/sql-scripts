 
/*  CLICC items charged out (still) during the COVID surge
    RR-532
*/
select distinct 
  p.last_name
, p.first_name 
, pa.address_line1 AS email_address
, itp.item_type_display as item_type
, mi.item_enum
, pg.patron_group_display as patron_group
, ct.charge_due_date
--, ct.charge_date

from circ_transactions ct
inner join location l on ct.charge_location = l.location_id
inner join item i on ct.item_id = i.item_id
inner join mfhd_item mi on i.item_id = mi.item_id
inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id --and ib.barcode_status = 1 --Active
inner join patron_barcode pb on ct.patron_id = pb.patron_id and ct.patron_group_id = pb.patron_group_id --and pb.barcode_status = 1 --Active
inner join patron p on pb.patron_id = p.patron_id
INNER JOIN patron_address pa ON p.patron_id = pa.patron_id
left outer join patron_group pg on pb.patron_group_id = pg.patron_group_id

where l.location_name like 'CLICC%' and pa.address_type = 3
 --BETWEEN trunc($P{startDate}) and trunc($P{endDate})
and ct.charge_date between to_date('20200304 000000', 'YYYYMMDD HH24MISS') and to_date('20200505 235959', 'YYYYMMDD HH24MISS')
--order by ct.charge_due_date
order by p.last_name
--, item_barcode
--order by patron_group, item_barcode
;
