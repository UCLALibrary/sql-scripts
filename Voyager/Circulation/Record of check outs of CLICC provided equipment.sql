/*  CLICC items charged out (still) during the COVID surge
    RR-532
*/
select distinct 
  p.last_name
, p.first_name
, pg.patron_group_display as patron_group
, p.institution_id
, mi.item_enum
--, mi.freetext
--, itp.item_type_display as item_type
, ib.item_barcode
--, p.last_name || ', ' || p.first_name as patron_name
--, pg.patron_group_display as patron_group
, ista.item_status_desc
, ct.charge_date
, ct.charge_due_date
, ct.discharge_date
--, ct.charge_date

from circ_transactions ct
inner join location l on ct.charge_location = l.location_id
inner join item i on ct.item_id = i.item_id
inner join mfhd_item mi on i.item_id = mi.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id --and ib.barcode_status = 1 --Active
inner join patron_barcode pb on ct.patron_id = pb.patron_id --and ct.patron_group_id = pb.patron_group_id --and pb.barcode_status = 1 --Active
inner join patron p on pb.patron_id = p.patron_id
inner join patron_group pg on pb.patron_group_id = pg.patron_group_id

where l.location_name like 'CLICC%'
and ct.charge_date between to_date('20200301', 'YYYYMMDD') AND to_date('20201201', 'YYYYMMDD')


 
order by p.last_name

