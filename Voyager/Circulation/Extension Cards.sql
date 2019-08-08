select
  p.normal_last_name,
  p.normal_first_name,
  pb.patron_barcode,
  pa.ADDRESS_LINE1 as email,
  to_char(p.expire_date, 'YYYY-MM-DD') as expire_date
from
  ucladb.patron_barcode pb
  inner join ucladb.patron p on pb.patron_id = p.patron_id
  left outer join ucladb.patron_address pa on p.patron_id = pa.patron_id and pa.address_type = 3
where
  pb.patron_group_id = 27
  and pb.barcode_status = 1
  and trunc(p.expire_date) >= trunc(sysdate)
order by
  p.normal_last_name,
  p.normal_first_name;
