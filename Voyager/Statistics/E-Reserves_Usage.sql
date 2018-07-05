create table vger_report.eres_web_logs (
  status int
, request_date date
, host varchar2(100)
, method varchar2(10)
, url varchar2(500)
, params varchar2(500)
)
;
-- Data imported via sqlldr

-- Data exported to Excel
with d as (
  select
    to_char(request_date, 'YYYYMM') as month
  , regexp_substr(url,'[^/]+',1,1) as library
  , regexp_substr(url,'[^/]+',1,2) as quarter
  , regexp_substr(url,'[^/]+',1,3) as subj_area
  from vger_report.eres_web_logs
)
select
  month
, library
, quarter
, subj_area
, count(*) as requests
from d
where month between '201607' and '201706' -- CHANGE each FY, if retaining data; can omit if working with only one FY
group by month, library, quarter, subj_area
order by month, library, quarter, subj_area
;

