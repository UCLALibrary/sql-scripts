/*  Data about YRLSC records at SRLF.
    Bibs with holdings at both sryr2 and yrspsr
    RR-260
    
    Per specs from Jira:
    Column 1: (RecordID)
    Column 2 (852_8_sryr2_Callnumber): <852>8_ $b sryr2 $k $h $I
    Column 3 (852_8_sryr2_Holding): holdings record number
    Column 4 (852_0_sryr2_Callnumber): <852>0 $b sryr2 $k $h $I
    Column 5 (852_0_sryr2_Holding): holdings record number
    
    with all associated
    Column 6 (852_0_yrspsr_Callnumber): <852>0_ $b yrspsr $k $h $I
    Column 7 (852_0_yrspsr_Holding): holdings record number
    or
    Column 8 (852_8_yrspsr_Callnumber): <852>8_ $b yrspsr $k $h $I
    Column 9 (852_8_yrspsr_Holding): holdings record number
*/

with all_data as (
select
  l.location_code
, bm.bib_id
, bm.mfhd_id
, mm.call_no_type
, mm.display_call_no
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code in ('sryr2', 'yrspsr')
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
--select count(distinct bib_id), count(*) from filtered --67823, 136152
select
  f1.bib_id as RecordID
  -- sryr2 data
, case when f1.ind1 = '8' then f1.display_call_no end as f852_8_sryr2_Callnumber
, case when f1.ind1 = '8' then f1.mfhd_id end as f852_8_sryr2_Holding
, case when f1.ind1 = '0' then f1.display_call_no end as f852_0_sryr2_Callnumber
, case when f1.ind1 = '0' then f1.mfhd_id end as f852_0_sryr2_Holding
  -- yrspsr data - 0/8 reversed from sryr2 above
, case when f2.ind1 = '0' then f2.display_call_no end as f852_0_yrspsr_Callnumber
, case when f2.ind1 = '0' then f2.mfhd_id end as f852_0_yrspsr_Holding
, case when f2.ind1 = '8' then f2.display_call_no end as f852_8_yrspsr_Callnumber
, case when f2.ind1 = '8' then f2.mfhd_id end as f852_8_yrspsr_Holding
from filtered f1
inner join filtered f2 
  on f1.bib_id = f2.bib_id
  and f1.location_code = 'sryr2'
  and f2.location_code = 'yrspsr'
--where f1.bib_id in (1581589, 658100, 5997416, 7128095)
order by f1.bib_id, f1.mfhd_id, f2.mfhd_id
;
-- 68377 rows total, due to some bibs having multiple holdings from one or the other location (or both)

