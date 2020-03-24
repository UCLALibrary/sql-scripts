--originally for RR 534
SELECT
    normal_last_name AS lasr_name,
    normal_first_name AS first_name,
    pb.patron_barcode AS barcode,
    --pb.barcode_status,
    pg.patron_group_display AS patron_group,
    p.expire_date,
    pa.address_line1,
    pa.address_line2,
    pa.address_line3,
    pa.address_line4,
    pa.address_line5,
    pa.city,
    pa.state_province,
    pa.zip_postal,
    pa.country,
    pe.address_line1 AS email
FROM
    ucladb.patron p
    inner join ucladb.patron_barcode pb on p.patron_id = pb.patron_id
    inner join ucladb.patron_group pg on pb.patron_group_id = pg.patron_group_id
    left join ucladb.patron_address pa on p.patron_id = pa.patron_id AND pa.address_id = ucladb.getPatronActiveAddress(p.patron_id)
    left join ucladb.patron_address pe on p.patron_id = pe.patron_id and pe.address_type = 3
WHERE
    p.expire_date < to_date('2019-02-02', 'YYYY-MM-DD')
    AND pb.patron_group_id in (8,24,28,31,34,36,40,44)
    AND pb.patron_barcode_id = ucladb.getFirstPatronBarcodeID(pb.patron_id)
ORDER BY
    last_name, 
    barcode
;
