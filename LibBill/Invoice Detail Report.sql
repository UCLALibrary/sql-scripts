SELECT DISTINCT
  ivw.invoice_number,
  invw.note,
  ilf.service_name,
  ilf.subtype_name,
  l.fau,
  ilf.unit_price,
  ilf.total_price,
  ila.adjustment_amount,
  decode(p.uc_community, 0, 'non-UC', 'UC') AS uc_community,
  decode(ivw.patron_on_premises, 'Y', 'on-site', 'off-site') as patron_on_premises,
  -- Patron name & basic address added per GHR-184257 akohler 20151118
  p.normal_last_name || ', ' || p.normal_first_name as patron_name,
  p.perm_address1,
  p.perm_address2,
  p.perm_address3,
  p.perm_address4,
  p.perm_address5,
  p.perm_city,
  p.perm_state,
  p.perm_zip,
  p.perm_country
FROM 
  invoice_owner.invoice_vw ivw
  LEFT OUTER JOIN invoice_owner.invoice_line_full_vw ilf ON ivw.invoice_number = ilf.invoice_number 
  LEFT OUTER JOIN invoice_owner.invoice_adjustment_vw iav ON ivw.invoice_number = iav.invoice_number
  LEFT OUTER JOIN invoice_owner.payment_vw pvw ON ivw.invoice_number = pvw.invoice_number
  LEFT OUTER JOIN invoice_owner.invoice_note_vw invw ON ivw.invoice_number = invw.invoice_number
  LEFT OUTER JOIN invoice_owner.invoice_line_adjustment_vw ila ON ivw.invoice_number = ila.invoice_number
  LEFT OUTER JOIN invoice_owner.PATRON_VW p ON ivw.patron_id = p.patron_id
  LEFT OUTER JOIN invoice_owner.location_service_vw l ON ilf.location_service_id = l.location_service_id
WHERE 
  ivw.invoice_date BETWEEN to_date(#prompt('Date_1')#, 'YYYY-MM-DD') AND to_date(#prompt('Date_2')#, 'YYYY-MM-DD') 
  AND substr(ivw.invoice_number, 1, 2) IN (#promptmany('Unit_Code')#)
  AND ivw.status IN (#promptmany('Invoice_status')#)
ORDER BY 
  ivw.invoice_number
