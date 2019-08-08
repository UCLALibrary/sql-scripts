SELECT DISTINCT
  TO_CHAR(p.create_date,'fmMM/ DD/ YYYY')  create_date,
  TO_CHAR(p.expire_date,'fmMM/ DD/ YYYY')  expire_date,
  pb.patron_barcode,
  p.last_name,
  p.first_name,
  perm_add.address_line1,
  perm_add.address_line2,
  perm_add.city,
  perm_add.state_province,
  perm_add.zip_postal,
 -- perm_phone_primary.phone_number,
  email.address_line1 email,
  pg.patron_group_name patron_group,
  vger_support.lws_csc.concat_stat_cats(p.patron_id) stat_cats,
  i.historical_charges

from
  ucladb.patron p
-- Join with Voyager's patron_barcode table. Pick only active status barcodes.

INNER JOIN CIRC_TRANSACTIONS cta ON p.PATRON_ID = cta.PATRON_ID
INNER JOIN ITEM i ON cta.ITEM_ID = i.ITEM_ID

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
  --p.create_date >= to_date('2006-01', 'YYYY-MM')
  --and
  (
    pg.patron_group_name = 'External 200 - Faculty'
    or pg.patron_group_name = 'External 200 - Other'
  )
order by
  p.last_name,
  p.first_name
