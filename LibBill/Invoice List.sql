select 
pat.last_name, 
pat.first_name, 
pat.institution_id, 
inv.*,
substr(invoice_number, 3, 10) as sort_number

from invoice_owner.invoice_vw inv

inner join ucladb.patron pat on inv.patron_id = pat.patron_id

where inv.invoice_date BETWEEN to_date(#prompt('Date_1')#, 'YYYY-MM-DD') and to_date(#prompt('Date_2')#, 'YYYY-MM-DD') 

and substr(inv.invoice_number, 1, 2) in (#promptmany('Unit_Code')#)
and inv.status in (#promptmany('Invoice_status')#)
