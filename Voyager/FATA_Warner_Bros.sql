/*  FATA report on Warner Brothers cartoons.
    https://jira.library.ucla.edu/browse/RR-253
*/

with bibs as (
  select
    record_id as bib_id
  , subfield as series
  from vger_subfields.filmntvdb_bib_subfield
  where tag in ('440a', '490a', '430')
  and (upper(subfield) like 'LOONEY TUNES%' or upper(subfield) like 'MERRIE MELODIES%')
  -- exclude The golden age of Looney tunes?
)
select
  b.bib_id
, mm.mfhd_id
, bt.pub_dates_combined as dates
, mm.display_call_no as call_number
, (select count(*) from filmntvdb.mfhd_item where mfhd_id = mm.mfhd_id) as items
, case substr(mm.field_007, 1, 2) -- 007/00-01
    when 'mr' then 'Film reel'
    when 'vd' then 'Videodisc'
    when 'vf' then 'Videocassette'
    else substr(mm.field_007, 1, 2) || ' : UNKNOWN'
  end as smd
, case
    -- check 007/07, but only for motion pictures based on 007/00
    when substr(mm.field_007, 1, 1) = 'm' and substr(mm.field_007, 8, 1) = 'd' then '16 mm'
    when substr(mm.field_007, 1, 1) = 'm' and substr(mm.field_007, 8, 1) = 'f' then '35 mm'
    when substr(mm.field_007, 1, 1) = 'm' and substr(mm.field_007, 8, 1) not in ('d', 'f') then substr(mm.field_007, 8, 1) || ' : UNKNOWN'
  end as dimensions
, case
    -- check 007/12, but only for motion pictures based on 007/00
    when substr(mm.field_007, 1, 1) = 'm' and substr(mm.field_007, 13, 1) = 'i' then 'Nitrate base'
    when substr(mm.field_007, 1, 1) = 'm' and substr(mm.field_007, 13, 1) = 'p' then 'Safety base, polyester'
    when substr(mm.field_007, 1, 1) = 'm' and substr(mm.field_007, 13, 1) = 't' then 'Safety base, triacetate'
    when substr(mm.field_007, 1, 1) = 'm' and substr(mm.field_007, 13, 1) not in ('i', 'p', 't') then substr(mm.field_007, 13, 1) || ' : UNKNOWN'
  end as base_of_film
, b.series
, vger_support.unifix(bt.title) as title
from bibs b
inner join filmntvdb.bib_text bt on b.bib_id = bt.bib_id
inner join filmntvdb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join filmntvdb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
order by smd, dimensions, base_of_film
;

