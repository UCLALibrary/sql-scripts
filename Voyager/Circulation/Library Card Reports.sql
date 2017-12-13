CURRENT ACTIVE
SELECT
    CASE
        WHEN pg.patron_group_id IN (20,24,28) THEN pg.patron_group_name
        ELSE DECODE(pg.patron_group_id,0,'No Group',report_group_desc)
    END AS patron_group,
    COUNT(pb.patron_id) AS patrons
FROM 
    ucladb.patron p
    INNER JOIN ucladb.patron_barcode pb ON p.patron_id = pb.patron_id
    INNER JOIN ucladb.patron_group pg ON pb.patron_group_id = pg.patron_group_id
    LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
    LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id 
WHERE 
    p.expire_date >= SYSDATE
    AND pb.barcode_status = 1
GROUP BY
    CASE
        WHEN pg.patron_group_id IN (20,24,28) THEN pg.patron_group_name
        ELSE DECODE(pg.patron_group_id,0,'No Group',report_group_desc)
    END
ORDER BY
    patron_group


ACADEMIC/LAW CARDS
SELECT
    p.institution_id, 
    pg.patron_group_name, 
    p.last_name, 
    pb.patron_barcode, 
    pbs.barcode_status_desc
FROM
    ucladb.patron p
    INNER JOIN ucladb.patron_barcode pb ON p.patron_id = pb.patron_id
    INNER JOIN ucladb.patron_group pg ON pb.patron_group_id = pg.patron_group_id
    INNER JOIN ucladb.patron_barcode_status pbs ON pb.barcode_status = pbs.barcode_status_type
    INNER JOIN ucladb.patron_stats ps ON p.patron_id = ps.patron_id
WHERE
    (pb.home_patron_group_id = 12 OR pb.patron_group_id = 12)
    AND
    ps.patron_stat_id = 26
ORDER BY 
    last_name 


ALUMNI CARDS
select
    TO_CHAR(p.create_date,'fmMM/ DD/ YYYY') AS create_date,
    p.last_name,
    p.first_name,
    email.address_line1 email
 
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
 p.create_date BETWEEN to_date(#prompt('date_1')#, 'YYYY-MM-DD') AND to_date(#prompt('date_2')#, 'YYYY-MM-DD')

  and

    pg.patron_group_name = 'External 5 - UCLA Alumni'
   -- or pg.patron_group_name = 'External 5 - Other'

order by
  p.create_date,
  p.last_name,
  p.first_name
