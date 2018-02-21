SELECT * FROM invoice_owner.location_service_vw
WHERE location_code in (#promptmany('Unit_code')#)
