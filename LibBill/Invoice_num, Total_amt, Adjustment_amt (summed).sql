SELECT 
  ivw.invoice_number,
  ivw.total_amount,
  sum(ila.adjustment_amount) as total_adjustment
 
FROM 
  invoice_owner.invoice_vw ivw
--  LEFT OUTER JOIN invoice_owner.invoice_line_full_vw ilf ON ivw.invoice_number = ilf.invoice_number 
  --LEFT OUTER JOIN invoice_owner.invoice_adjustment_vw iav ON ivw.invoice_number = iav.invoice_number
  --LEFT OUTER JOIN invoice_owner.payment_vw pvw ON ivw.invoice_number = pvw.invoice_number
  --LEFT OUTER JOIN invoice_owner.invoice_note_vw invw ON ivw.invoice_number = invw.invoice_number
  LEFT OUTER JOIN invoice_owner.invoice_line_adjustment_vw ila ON ivw.invoice_number = ila.invoice_number
 -- LEFT OUTER JOIN invoice_owner.PATRON_VW p ON ivw.patron_id = p.patron_id
WHERE 
  ivw.invoice_date BETWEEN to_date(#prompt('Date_1')#, 'YYYY-MM-DD') AND to_date(#prompt('Date_2')#, 'YYYY-MM-DD') 
  AND substr(ivw.invoice_number, 1, 2) IN (#promptmany('Unit_Code')#)
  AND ivw.status IN (#promptmany('Invoice_status')#)

GROUP BY 
 ivw.invoice_number, ivw.total_amount

ORDER BY 
  ivw.invoice_number
