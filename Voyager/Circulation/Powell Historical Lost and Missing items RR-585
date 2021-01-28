      
select distinct 
  ist.item_status_desc
, is_m.item_status_date
, bt.bib_id
, bt.author
, bt.title
, iv.call_no
, iv.barcode
--, l.location_display_name as perm_location
, il.location_name AS perm_location
, t_l.location_name AS temp_location
, ( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from bib_location bl
    inner join location l2 on bl.location_id = l2.location_id
    where bl.bib_id = bt.bib_id
    and l2.location_code != il.location_code
) as other_locs


, iv.enumeration
, i.copy_number
, pb.patron_barcode
, pg.patron_group_name
, ff.fine_fee_amount/100 as fine_fee
, ff.fine_fee_balance/100 as fine_fee_balance

from
    ucladb.item i
    inner join ucladb.bib_item bi ON i.item_id = bi.item_id
    inner join ucladb.bib_text bt ON bi.bib_id = bt.bib_id
    INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
    INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
    inner join ucladb.item_vw iv ON bi.item_id = iv.item_id
   -- inner join ucladb.location l on i.perm_location = l.location_id
    INNER JOIN ucladb.location il ON i.perm_location = il.location_id 
    inner join ucladb.item_status is_m ON i.item_id = is_m.item_id
    INNER JOIN ucladb.ITEM_STATUS_TYPE ist ON is_m.ITEM_STATUS = ist.ITEM_STATUS_TYPE

    inner join ucladb.circ_transactions ct on i.item_id = ct.item_id
    inner join ucladb.patron_barcode pb on ct.patron_id = pb.patron_id and ct.patron_group_id = pb.patron_group_id 
    inner join ucladb.patron_group pg on ct.patron_group_id = pg.patron_group_id
    left outer join fine_fee ff on pg.patron_group_id = ff.patron_id
    LEFT OUTER JOIN ucladb.location t_l ON i.temp_location = t_l.location_id 
    
where 
   il.location_name like 'Powell%'
   and 
   (is_m.item_status = 14 or is_m.item_status = 13 or is_m.item_status = 12)
     --AND is_m.item_status_date BETWEEN trunc($P{startDate}) and trunc($P{endDate})
  
    order by iv.call_no
    
    
   
