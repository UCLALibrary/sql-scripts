/*  Suppress certain cat-as-sep records
    VBT-1370
*/

-- Working table for BatchCat program and data review
create table vger_report.tmp_vbt_1370 as
-- Unsuppressed holdings for cat-as-seps (CSP)
with mfhds as (
  select
    bm.bib_id
  , bm.mfhd_id
  , l.location_code
  , mm.display_call_no
  from ucladb.mfhd_master mm
  inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
  inner join ucladb.location l on mm.location_id = l.location_id
  where lower(mm.display_call_no) like '%see%indiv%' -- checking on exact wording
  -- and lower(mm.display_call_no) != 'see individual records for call numbers'
  and mm.suppress_in_opac = 'N'
)
-- Unsuppressed holdings linked to the bibs for the CSP holdings above
, other_mfhds as (
  select distinct
    bm2.bib_id
  , bm2.mfhd_id
  , mm2.display_call_no
  , l2.location_code
  -- Collect info about call numbers (852 $h $i explicitly)
  , case
      when exists   ( select * from vger_subfields.ucladb_mfhd_subfield where record_id = bm2.mfhd_id and tag = '852h')
        and exists  ( select * from vger_subfields.ucladb_mfhd_subfield where record_id = bm2.mfhd_id and tag = '852i')
      then 'Y'
      else 'N'
    end as has_852hi
  from mfhds 
  inner join ucladb.bib_mfhd bm2 
    on mfhds.bib_id = bm2.bib_id
    and mfhds.mfhd_id != bm2.mfhd_id
  inner join ucladb.mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
  inner join ucladb.location l2 on mm2.location_id = l2.location_id
  where mm2.suppress_in_opac = 'N'
)
-- Main query: CSP holdings where 
-- * no other holdings on the bib have call number
-- * no other holdings on the bib are at SRLF
-- * bib record does not have an OCLC number
select
  m.*
, ( select listagg(om.location_code || ': ' || om.display_call_no, ' /// ') within group (order by om.location_code)
    from other_mfhds om
    where bib_id = m.bib_id
) as other_locs
from mfhds m
where not exists (
  select * from other_mfhds 
  where bib_id = m.bib_id
  and has_852hi = 'Y'
)
and not exists (
  select * from other_mfhds 
  where bib_id = m.bib_id
  and location_code like 'sr%'
)
and not exists (select * from ucladb.bib_index where bib_id = m.bib_id and index_code = '0350' and normal_heading like 'UCOCLC%')
order by m.bib_id, m.location_code
;

-- Let BatchCat program access the data
grant select on vger_report.tmp_vbt_1370 to ucla_preaddb;
select count(*), count(distinct mfhd_id) from vger_report.tmp_vbt_1370;
-- 9152 suppression candidates

-- Clean up
drop table vger_report.tmp_vbt_1370 purge;
