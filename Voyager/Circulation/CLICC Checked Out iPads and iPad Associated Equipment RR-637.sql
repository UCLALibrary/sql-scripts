  

select distinct 

  p.last_name || ', ' || p.first_name as patron_name
, p.institution_id
, ct.charge_date
--, ct.discharge_date
, ib.item_barcode
, mi.item_enum



from circ_transactions ct
inner join location l on ct.charge_location = l.location_id
inner join item i on ct.item_id = i.item_id
inner join mfhd_item mi on i.item_id = mi.item_id
inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id --and ib.barcode_status = 1 --Active
inner join patron_barcode pb on ct.patron_id = pb.patron_id --and ct.patron_group_id = pb.patron_group_id --and pb.barcode_status = 1 --Active
inner join patron p on pb.patron_id = p.patron_id
--inner join patron_group pg on pb.patron_group_id = pg.patron_group_id

where l.location_name like 'CLICC%'
        and (mi.item_enum like 'ITS iPad%'
        or mi.item_enum like 'CLICC Faculty iPad%'
        or mi.item_enum like 'CLICC iPad Keyboard%')

order by p.last_name || ', ' || p.first_name
 



