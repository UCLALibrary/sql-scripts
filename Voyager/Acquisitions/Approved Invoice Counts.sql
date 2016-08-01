/*  Count of invoices approved by specific staff in FY.
    Note imprecision: Voyager does not track who changed status, just
    when status changed (most recently) and who updated invoice (most recently).
    https://jira.library.ucla.edu/browse/RR-192
*/
select
  to_char(trunc(i.invoice_status_date, 'MM'), 'YYYY-MON') as month
, count(*) as invoices
from invoice i
inner join invoice_status ist on i.invoice_status = ist.invoice_status
where ist.invoice_status_desc = 'Approved'
and i.invoice_status_date between to_date('20150701', 'YYYYMMDD') and to_date('20160701', 'YYYYMMDD')
--and i.update_opid = 'abaxley'
group by trunc(i.invoice_status_date, 'MM') --, i.update_opid
order by trunc(i.invoice_status_date, 'MM')
;
