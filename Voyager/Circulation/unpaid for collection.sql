WITH external_charges AS 
( 
    SELECT 
        ff.fine_fee_id,
        ff.patron_id, 
        p.institution_id, 
        p.normal_last_name || ', ' || p.normal_first_name AS patron_name,
        pg.patron_group_display AS patron_group, 
        ff.fine_fee_balance,
        ff.item_id, 
        ff.fine_fee_type,
        vger_support.get_related_processing_fee(ff.patron_id,ff.item_id) AS related_processing_fee,
        CASE 
            WHEN ff.fine_fee_type = 2 THEN 1 
            ELSE 0 
        END AS is_a_lost_item_replacement, 
        i.perm_location,
        il.location_code,
        ff.create_date fine_date, 
        p.expire_date patron_expired 
    FROM 
        ucladb.fine_fee ff 
        INNER JOIN ucladb.patron p ON ff.patron_id = p.patron_id 
        -- Join with Voyager's patron_barcode table. Pick only active status barcodes. 
        INNER JOIN ucladb.PATRON_BARCODE pb ON pb.patron_id = p.patron_id AND pb.barcode_status = 1 
        -- Join with Voyager's patron_group table. 
        INNER JOIN ucladb.PATRON_GROUP pg ON pg.patron_group_id = pb.patron_group_id 
        -- Join with patron_group_components table. 
        INNER JOIN vger_support.PATRON_GROUP_COMPONENTS pgc ON pgc.patron_group_id = pg.patron_group_id 
        INNER JOIN ucladb.item i ON ff.item_id = i.item_id 
        INNER JOIN ucladb.location il ON i.perm_location = il.location_id 
        INNER JOIN ucladb.circ_policy_locs cpl ON i.perm_location = cpl.location_id 
        INNER JOIN vger_support.CB_SUBCODES sc ON vger_support.lws_cb.GET_SUBCODE_KEY(cpl.circ_group_id, il.location_code) = sc.circ_group_id AND ff.fine_fee_type = sc.fine_fee_type 
    WHERE 
        ff.fine_fee_balance > 0 
        AND 
        (
            ff.fine_fee_type = 2 
            OR 
            (ff.fine_fee_type <> 2 AND exists (SELECT * FROM ucladb.fine_fee ff2 WHERE ff2.fine_fee_type = 2 AND ff2.fine_fee_balance > 0 AND ff2.patron_id = ff.patron_id AND ff2.item_id = ff.item_id))
        )
        AND (pgc.TYPE <> 2 AND pgc.TYPE <> 3 AND pb.patron_group_id NOT IN (1,3,8,12,13,16,29,32,33,38,39,40,45,46,48)) 
        -- Pick only records that have one active barcode. 
        AND NOT EXISTS 
        ( 
            SELECT 
                * 
            FROM 
                ucladb.PATRON_BARCODE pb2 
            WHERE 
                pb2.patron_id = p.patron_id 
                AND pb2.patron_barcode_id <> pb.patron_barcode_id 
                AND pb2.barcode_status = 1 
        ) 
    ORDER BY 
        ff.patron_id
),
staff_charges AS 
( 
    SELECT 
        ff.fine_fee_id,
        ff.patron_id, 
        p.institution_id, 
        p.normal_last_name || ', ' || p.normal_first_name AS patron_name,
        pg.patron_group_display AS patron_group, 
        ff.fine_fee_balance,
        ff.item_id, 
        ff.fine_fee_type,
        vger_support.get_related_processing_fee(ff.patron_id,ff.item_id) AS related_processing_fee,
        CASE 
            WHEN ff.fine_fee_type = 2 THEN 1 
            ELSE 0 
        END AS is_a_lost_item_replacement, 
        i.perm_location , 
        il.location_code,
        ff.create_date fine_date, 
        p.expire_date patron_expired 
    FROM 
        ucladb.fine_fee ff 
        INNER JOIN ucladb.patron p ON ff.patron_id = p.patron_id 
        -- Join with Voyager's patron_barcode table. Pick only active status barcodes. 
        INNER JOIN ucladb.PATRON_BARCODE pb ON pb.patron_id = p.patron_id AND pb.barcode_status = 1 
        -- Join with Voyager's patron_group table. 
        INNER JOIN ucladb.PATRON_GROUP pg ON pg.patron_group_id = pb.patron_group_id 
        -- Join with patron_group_components table. 
        INNER JOIN vger_support.PATRON_GROUP_COMPONENTS pgc ON pgc.patron_group_id = pg.patron_group_id 
        INNER JOIN ucladb.item i ON ff.item_id = i.item_id 
        INNER JOIN ucladb.location il ON i.perm_location = il.location_id 
        INNER JOIN ucladb.circ_policy_locs cpl ON i.perm_location = cpl.location_id 
        INNER JOIN vger_support.CB_SUBCODES sc ON vger_support.lws_cb.GET_SUBCODE_KEY(cpl.circ_group_id, il.location_code) = sc.circ_group_id AND ff.fine_fee_type = sc.fine_fee_type 
    WHERE 
        ff.fine_fee_balance > 0 
        AND 
        (
            ff.fine_fee_type = 2 
            OR 
            (ff.fine_fee_type <> 2 AND exists (SELECT * FROM ucladb.fine_fee ff2 WHERE ff2.fine_fee_type = 2 AND ff2.fine_fee_balance > 0 AND ff2.patron_id = ff.patron_id AND ff2.item_id = ff.item_id))
        )
        AND pb.patron_group_id IN (3,16,45,46)  
        -- Pick only records that have one active barcode. 
        AND NOT EXISTS 
        ( 
            SELECT 
                * 
            FROM 
                ucladb.PATRON_BARCODE pb2 
            WHERE 
                pb2.patron_id = p.patron_id 
                AND pb2.patron_barcode_id <> pb.patron_barcode_id 
                AND pb2.barcode_status = 1 
        ) 
    ORDER BY 
        ff.patron_id
),
student_charges AS 
( 
    SELECT 
        ff.fine_fee_id,
        ff.patron_id, 
        p.institution_id, 
        p.normal_last_name || ', ' || p.normal_first_name AS patron_name,
        pg.patron_group_display AS patron_group, 
        ff.fine_fee_balance,
        ff.item_id, 
        ff.fine_fee_type,
        vger_support.get_related_processing_fee(ff.patron_id,ff.item_id) AS related_processing_fee,
        CASE 
            WHEN ff.fine_fee_type = 2 THEN 1 
            ELSE 0 
        END AS is_a_lost_item_replacement, 
        i.perm_location , 
        il.location_code,
        ff.create_date fine_date, 
        p.expire_date patron_expired 
    FROM 
        ucladb.fine_fee ff 
        INNER JOIN ucladb.patron p ON ff.patron_id = p.patron_id 
        -- Join with Voyager's patron_barcode table. Pick only active status barcodes. 
        INNER JOIN ucladb.PATRON_BARCODE pb ON pb.patron_id = p.patron_id AND pb.barcode_status = 1 
        -- Join with Voyager's patron_group table. 
        INNER JOIN ucladb.PATRON_GROUP pg ON pg.patron_group_id = pb.patron_group_id 
        -- Join with patron_group_components table. 
        INNER JOIN vger_support.PATRON_GROUP_COMPONENTS pgc ON pgc.patron_group_id = pg.patron_group_id 
        INNER JOIN ucladb.item i ON ff.item_id = i.item_id 
        INNER JOIN ucladb.location il ON i.perm_location = il.location_id 
        INNER JOIN ucladb.circ_policy_locs cpl ON i.perm_location = cpl.location_id 
        INNER JOIN vger_support.CB_SUBCODES sc ON vger_support.lws_cb.GET_SUBCODE_KEY(cpl.circ_group_id, il.location_code) = sc.circ_group_id AND ff.fine_fee_type = sc.fine_fee_type 
    WHERE 
        ff.fine_fee_balance > 0 
        AND 
        (
            ff.fine_fee_type = 2 
            OR 
            (ff.fine_fee_type <> 2 AND exists (SELECT * FROM ucladb.fine_fee ff2 WHERE ff2.fine_fee_type = 2 AND ff2.fine_fee_balance > 0 AND ff2.patron_id = ff.patron_id AND ff2.item_id = ff.item_id))
        )
        AND (pgc.TYPE  = 2 OR pgc.TYPE  = 3) 
        -- Pick only records that have one active barcode. 
        AND NOT EXISTS 
        ( 
            SELECT 
                * 
            FROM 
                ucladb.PATRON_BARCODE pb2 
            WHERE 
                pb2.patron_id = p.patron_id 
                AND pb2.patron_barcode_id <> pb.patron_barcode_id 
                AND pb2.barcode_status = 1 
        ) 
        AND NOT EXISTS 
        ( 
             SELECT 
                * 
             FROM 
                vger_report.cmp_registrar reg 
             WHERE 
                p.institution_id = reg.university_id 
             -- Students in the Registrar data are active if the withdraw field is null. 
                AND reg.withdraw IS NULL 
        ) 
    ORDER BY 
        ff.patron_id
) 
SELECT 
    fine_fee_id,
    item_barcode,
    call_no,
    enumeration,
    title,
    author,
    location,
    patron_name,
    university_id,
    address_line1,
    address_line2,
    address_line3,
    address_line4,
    address_line5,
    city,
    state_province,
    zip_postal,
    country,
    phone_number,
    to_char(fine_date, 'MM/DD/YYYY') as fine_date, 
    fine_fee_type,
    fine_fee_balance
FROM 
( 
    SELECT 
        DECODE(t_l.location_name, NULL, l.location_name, t_l.location_name) AS location, 
        fine_fee_id,
        institution_id AS university_id, 
        patron_name,
        ec.patron_id,
        fine_date, 
        fftp.fine_fee_desc fine_fee_type,
        fine_fee_balance / 100 AS fine_fee_balance,
        related_processing_fee,
        patron_group, 
        unifix(bt.TITLE) AS title, 
        unifix(bt.author) AS author, 
        iv.barcode as item_barcode, 
        iv.call_no as call_no, 
        bi.bib_id,
        iv.enumeration as enumeration,
        pa.address_line1,
        pa.address_line2,
        pa.address_line3,
        pa.address_line4,
        pa.address_line5,
        pa.city,
        pa.state_province,
        pa.zip_postal,
        pa.country,
        pp.phone_number
    FROM 
        external_charges ec 
        INNER JOIN ucladb.item i ON ec.item_id = i.item_id 
        INNER JOIN ucladb.location il ON i.perm_location = il.location_id 
        LEFT OUTER JOIN ucladb.location l ON i.perm_location = l.location_id 
        LEFT OUTER JOIN ucladb.location t_l ON i.temp_location = t_l.location_id 
        INNER JOIN ucladb.bib_item bi ON ec.item_id = bi.item_id 
        INNER JOIN ucladb.bib_text bt ON bi.bib_id = bt.bib_id 
        INNER JOIN ucladb.item_vw iv ON bi.item_id = iv.item_id 
        LEFT OUTER JOIN ucladb.fine_fee_type fftp ON ec.fine_fee_type = fftp.fine_fee_type
        INNER JOIN ucladb.patron_address pa on ec.patron_id = pa.patron_id and pa.address_type = 1 and pa.address_status <> 'H'
        LEFT OUTER JOIN ucladb.patron_phone pp on pa.address_id = pp.address_id and pp.phone_type = 1
    WHERE
      TO_CHAR(ec.fine_date, 'YYYY') between '2004' and '2009'
)
UNION
SELECT 
    fine_fee_id,
    item_barcode,
    call_no,
    enumeration,
    title,
    author,
    location,
    patron_name,
    university_id,
    address_line1,
    address_line2,
    address_line3,
    address_line4,
    address_line5,
    city,
    state_province,
    zip_postal,
    country,
    phone_number,
    to_char(fine_date, 'MM/DD/YYYY') as fine_date, 
    fine_fee_type,
    fine_fee_balance
FROM 
( 
    SELECT 
        DECODE(t_l.location_name, NULL, l.location_name, t_l.location_name) AS location, 
        fine_fee_id,
        institution_id AS university_id, 
        patron_name,
        stc.patron_id,
        fine_date, 
        fftp.fine_fee_desc fine_fee_type,
        fine_fee_balance / 100 AS fine_fee_balance,
        related_processing_fee,
        patron_group, 
        unifix(bt.TITLE) AS title, 
        unifix(bt.author) AS author, 
        iv.barcode as item_barcode, 
        iv.call_no as call_no, 
        bi.bib_id,
        iv.enumeration as enumeration,
        pa.address_line1,
        pa.address_line2,
        pa.address_line3,
        pa.address_line4,
        pa.address_line5,
        pa.city,
        pa.state_province,
        pa.zip_postal,
        pa.country,
        pp.phone_number
    FROM 
        staff_charges stc 
        INNER JOIN ucladb.item i ON stc.item_id = i.item_id 
        INNER JOIN ucladb.location il ON i.perm_location = il.location_id 
        LEFT OUTER JOIN ucladb.location l ON i.perm_location = l.location_id 
        LEFT OUTER JOIN ucladb.location t_l ON i.temp_location = t_l.location_id 
        INNER JOIN ucladb.bib_item bi ON stc.item_id = bi.item_id 
        INNER JOIN ucladb.bib_text bt ON bi.bib_id = bt.bib_id 
        INNER JOIN ucladb.item_vw iv ON bi.item_id = iv.item_id 
        LEFT OUTER JOIN ucladb.fine_fee_type fftp ON stc.fine_fee_type = fftp.fine_fee_type
        INNER JOIN ucladb.patron_address pa on stc.patron_id = pa.patron_id and pa.address_type = 1 and pa.address_status <> 'H'
        LEFT OUTER JOIN ucladb.patron_phone pp on pa.address_id = pp.address_id and pp.phone_type = 1
    WHERE
      TO_CHAR(stc.fine_date, 'YYYY') between '2004' and '2009'
)
UNION
SELECT 
    fine_fee_id,
    item_barcode,
    call_no,
    enumeration,
    title,
    author,
    location,
    patron_name,
    university_id,
    address_line1,
    address_line2,
    address_line3,
    address_line4,
    address_line5,
    city,
    state_province,
    zip_postal,
    country,
    phone_number,
    to_char(fine_date, 'MM/DD/YYYY') as fine_date, 
    fine_fee_type,
    fine_fee_balance
FROM 
( 
    SELECT 
        DECODE(t_l.location_name, NULL, l.location_name, t_l.location_name) AS location, 
        fine_fee_id,
        institution_id AS university_id, 
        patron_name,
        sc.patron_id,
        fine_date, 
        fftp.fine_fee_desc fine_fee_type,
        fine_fee_balance / 100 AS fine_fee_balance,
        related_processing_fee,
        patron_group, 
        unifix(bt.TITLE) AS title, 
        unifix(bt.author) AS author, 
        iv.barcode as item_barcode, 
        iv.call_no as call_no, 
        bi.bib_id,
        iv.enumeration as enumeration,
        pa.address_line1,
        pa.address_line2,
        pa.address_line3,
        pa.address_line4,
        pa.address_line5,
        pa.city,
        pa.state_province,
        pa.zip_postal,
        pa.country,
        pp.phone_number
    FROM 
        student_charges sc 
        INNER JOIN ucladb.item i ON sc.item_id = i.item_id 
        INNER JOIN ucladb.location il ON i.perm_location = il.location_id 
        LEFT OUTER JOIN ucladb.location l ON i.perm_location = l.location_id 
        LEFT OUTER JOIN ucladb.location t_l ON i.temp_location = t_l.location_id 
        INNER JOIN ucladb.bib_item bi ON sc.item_id = bi.item_id 
        INNER JOIN ucladb.bib_text bt ON bi.bib_id = bt.bib_id 
        INNER JOIN ucladb.item_vw iv ON bi.item_id = iv.item_id 
        LEFT OUTER JOIN ucladb.fine_fee_type fftp ON sc.fine_fee_type = fftp.fine_fee_type
        INNER JOIN ucladb.patron_address pa on sc.patron_id = pa.patron_id and pa.address_type = 1 and pa.address_status <> 'H'
        LEFT OUTER JOIN ucladb.patron_phone pp on pa.address_id = pp.address_id and pp.phone_type = 1
    WHERE
      TO_CHAR(sc.fine_date, 'YYYY') between '2004' and '2009'
)
