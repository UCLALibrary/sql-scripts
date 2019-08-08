SELECT

patron.last_name,
patron.first_name,
patron_barcode.patron_barcode,
patron.institution_id,
patron.create_operator_id


FROM patron

INNER JOIN PATRON_BARCODE ON PATRON.PATRON_ID = PATRON_BARCODE.PATRON_ID

WHERE home_location = '111' AND create_date >= to_date('20140701', 'YYYYMMDD')

ORDER BY patron.last_name
