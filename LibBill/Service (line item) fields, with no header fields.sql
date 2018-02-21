SELECT
invoice_number,
line_number,
location_service_id,
quantity, 
unit_price,
total_price
 
FROM invoice_owner.invoice_line_vw
