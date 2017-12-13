CREATED SINCE 2006
select 
  p.last_name,
  p.first_name,
  perm_add.address_line1,
  perm_add.address_line2,
  perm_add.city,
  perm_add.state_province,
  perm_add.zip_postal,
  perm_phone_primary.phone_number,
  email.address_line1 email,
  pg.patron_group_name patron_group,
  vger_support.lws_csc.concat_stat_cats(p.patron_id) stat_cats
from 
  ucladb.patron p
-- Join with Voyager's patron_barcode table. Pick only active status barcodes.
inner join 
  ucladb.PATRON_BARCODE pb on pb.patron_id = p.patron_id and pb.barcode_status = 1
-- Join with Voyager's patron_group table.
inner join 
  ucladb.PATRON_GROUP pg on pg.patron_group_id = pb.patron_group_id
-- Join with Voyager's patron_address table. Pick only permanent address records.
inner join 
  ucladb.PATRON_ADDRESS perm_add on perm_add.patron_id = p.patron_id and perm_add.address_type = 1
-- Join with Voyager's patron_phone table for phone (primary).
left outer join 
  ucladb.PATRON_PHONE perm_phone_primary on perm_phone_primary.address_id = perm_add.address_id and perm_phone_primary.phone_type = 1
-- Join with Voyager's patron_address table. Pick only e-mail address records.
left outer join 
  ucladb.PATRON_ADDRESS email on email.patron_id = p.patron_id and email.address_type = 3
where
  p.create_date >= to_date('2006-01', 'YYYY-MM')
  and 
  (
    pg.patron_group_name = 'External 5 - UCLA Alumni'
    or pg.patron_group_name = 'External 5 - Other'
  )
order by 
  p.last_name,
  p.first_name


ALUMNI ISSUED/RENEWED
SELECT
pb.patron_barcode,
CASE 
WHEN TRUNC(pb.barcode_status_date) BETWEEN TRUNC(TO_DATE('20080701', 'YYYYMMDD')) AND TRUNC(TO_DATE('20090701', 'YYYYMMDD')) THEN 'issued'
WHEN TRUNC(p.expire_date) BETWEEN TRUNC(TO_DATE('20090701', 'YYYYMMDD')) AND TRUNC(TO_DATE('20100701', 'YYYYMMDD')) THEN 'renewed'
ELSE 'unknown'
END AS card_type
FROM 
ucladb.patron p
inner join ucladb.patron_barcode pb ON p.patron_id = pb.patron_id
WHERE 
-- pick the patron group we're interested in.
pb.patron_group_id = 2
AND
-- pick issed and renewed cards.
(
-- issued.
TRUNC(pb.barcode_status_date) BETWEEN TRUNC(TO_DATE('20080701', 'YYYYMMDD')) AND TRUNC(TO_DATE('20090701', 'YYYYMMDD'))
OR
-- renewed (expires the following year).
TRUNC(p.expire_date) BETWEEN TRUNC(TO_DATE('20090701', 'YYYYMMDD')) AND TRUNC(TO_DATE('20100701', 'YYYYMMDD'))
)
-- pick out the active patron barcode, or the one with the lowest number status
-- if there isn't an active one.
AND NOT EXISTS
(
SELECT * FROM ucladb.patron_barcode pb2
WHERE pb.patron_id = pb2.patron_id
AND 
(
pb.barcode_status > pb2.barcode_status  OR 
(
pb.barcode_status = pb2.barcode_status AND pb2.patron_barcode_id < pb.patron_barcode_id
)
)
)


BY YEAR
SELECT
p.last_name || ', ' || p.first_name AS patron_name,
ma.address_line1,
ma.address_line2,
ma.city,
ma.state_province,
ma.zip_postal,
ma.country,
ea.address_line1 AS email
FROM 
ucladb.patron p
inner join ucladb.patron_barcode pb ON p.patron_id = pb.patron_id
left outer join ucladb.patron_address ma ON p.patron_id = ma.patron_id
left outer join ucladb.patron_address ea ON p.patron_id = ea.patron_id
WHERE
pb.patron_group_id = 11
AND TRUNC(p.create_date) BETWEEN TRUNC(TO_DATE('07/01/2007','MM/DD/YYYY')) AND TRUNC(TO_DATE('06/30/2008','MM/DD/YYYY')) 
AND ma.address_type = 1
AND ea.address_type = 3
ORDER BY
patron_name

