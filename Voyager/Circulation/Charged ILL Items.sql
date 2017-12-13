select 
  pb.patroN_barcode,
  ib.item_barcode,
  ct.CURRENT_DUE_DATE
from 
  ucladb.circ_transactions ct
  inner join ucladb.item i on ct.item_id = i.item_id
  inner join ucladb.item_barcode ib on i.item_id = ib.item_id
  inner join ucladb.patron_barcode pb on ct.patron_id = pb.patron_id
where 
  i.item_type_id in (54,55,66)
  and pb.barcode_status = 1
  and trunc(ct.charge_date) = trunc(sysdate - 1)
