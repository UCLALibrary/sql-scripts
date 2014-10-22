/*
Requested annually by Janine Henri:
1- Number of LC class NA volumes in the Arts Library
2- Number of LC class NA volumes in the UCLA Library
3- Number of LC Class NA volumes added last FY to the Arts Library
4- Number of LC Class NA volumes added last FY to the UCLA Library
*/
-- CHANGE THE DATES
define start_date = '20130701';
define end_date = '20140701';

with items as (
  select
    substr(mm.normalized_call_no, 1, 3) as lc
  , substr(l.location_code, 1, 2) as unit
  , it.item_type_name as item_type
  from mfhd_master mm
  inner join location l on mm.location_id = l.location_id
  inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
  inner join item i on mi.item_id = i.item_id
  inner join item_type it on i.item_type_id = it.item_type_id
  where mm.normalized_call_no like 'NA%' 
  and mm.call_no_type = '0'
  -- Comment out the create_date criteria for questions 1-2; enable it for questions 3-4
  and i.create_date between to_date('&start_date', 'YYYYMMDD') and to_date('&end_date', 'YYYYMMDD')
  and item_type_name in (
    '1 day reserve'
  ,	'2 day reserve'
  ,	'2 hour reserve'
  ,	'3 day reserve'
  ,	'4 hour reserve'
  ,	'7 day reserve'
  ,	'Archival'
  ,	'Book'
  ,	'Book Oversize'
  ,	'Building Use'
  ,	'Journal'
  ,	'Journal02'
  ,	'Journal10'
  ,	'Map'
  ,	'Non-circulating'
  ,	'Reference'
  ,	'Score'
  ,	'SRLF Books'
  ,	'SRLF Journals'
  ,	'Tower Reading Room'
  )
)
-- Report the 'ar' count for questions 1 and 3; add up all counts (including 'ar') for questions 2 and 4
select
  unit, count(*) as num
from items
group by unit
order by unit
;
