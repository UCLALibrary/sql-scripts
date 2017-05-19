/*  Data about Biomed SC records at SRLF.
    Bibs with holdings at both biscsr and srbi2
    RR-273
*/

with all_data as (
select
  l.location_code
, bm.bib_id
, bm.mfhd_id
--, mm.call_no_type -- null when no call number, even though indicator 1 is set
, mm.display_call_no
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code in ('biscsr', 'srbi2')
)
, filtered as (
  select
    ad.*
  -- Some holdings have multiple 852 $b, almost certainly errors...
  , (select min(substr(indicators, 1, 1)) from vger_subfields.ucladb_mfhd_subfield where record_id = ad.mfhd_id and tag = '852b') as ind1
  from all_data ad
  where exists (
    select * from all_data
    where bib_id = ad.bib_id
    and location_code != ad.location_code
  )  
)
-- select count(distinct bib_id), count(*) from filtered; -- 10018, 20137
-- select location_code, count(*) as num from filtered group by location_code; -- biscsr 10100, srbi2 10037
select 
  f1.bib_id
, f1.mfhd_id as bi_mfhd_id
, f1.ind1 as bi_call_no_type
, f1.display_call_no as bi_call_number
, f2.mfhd_id as sr_mfhd_id
, f2.ind1 as sr_call_no_type
, f2.display_call_no as sr_call_number
from filtered f1
inner join filtered f2
  on f1.bib_id = f2.bib_id
  and f1.location_code = 'biscsr'
  and f2.location_code = 'srbi2'
where f1.ind1 in ('0', '8') and f2.ind1 in ('0', '8') -- report 1: 6576 rows
--where f1.ind1 = '2' and f2.ind1 = '2' -- report 2: 1948 rows
order by f1.bib_id, f1.mfhd_id, f2.mfhd_id
--order by length(f1.display_call_no) desc nulls last -- bad call numbers? (9100820, 7974099, 10609964)
;
