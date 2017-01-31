/*  Law SuDoc report
    Jira: https://jira.library.ucla.edu/browse/RR-242
*/

/*  Create working table of data for post-query analysis, 
    and because the full query takes 6.5 hours to run so
    not practical to export while it's running.
    
    Uses undocumented "materialize" hint, which helps with
    performance of sub-queries during development, but
    doesn't seem to help with full run performance (but 
    doesn't hurt either).
*/
create table vger_report.tmp_rr242 as
with law_mfhds as (
  select /*+ materialize */
    bm.mfhd_id
  , bm.bib_id
  , mm.display_call_no as call_number
  , mm.normalized_call_no as sort_call_number
  , bt.pub_dates_combined as pub_dates -- 008/07-14, not 260 $c
  from ucladb.location l
  inner join ucladb.mfhd_master mm on l.location_id = mm.location_id
  inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
  inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
  where l.location_code = 'lw' -- Law Stacks only
  and mm.call_no_type = '3' -- SuDocs
)
-- SRLF holdings linked to same bib records as Law holdings above
, law_srlf as (
  select /*+ materialize */
    bm2.bib_id
  , mm2.mfhd_id as srlf_mfhd_id
  , (select count(*) from ucladb.mfhd_item where mfhd_id = mm2.mfhd_id) as srlf_items
  , ( select subfield from vger_subfields.ucladb_mfhd_subfield
      where record_id = mm2.mfhd_id
      and tag = '866a'
      and rownum < 2
    ) as srlf_f866a
  from law_mfhds l
  inner join ucladb.bib_mfhd bm2 on l.bib_id = bm2.bib_id
  inner join ucladb.mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
  inner join ucladb.location l2 on mm2.location_id = l2.location_id
  where l2.location_code = 'sr' -- SRLF Stacks only
)
-- Internet holdings linked to the same bib records as Law holdings above
, law_internet as (
  select /*+ materialize */
    bm3.bib_id
  , mm3.mfhd_id as internet_mfhd_id
  from law_mfhds l
  inner join ucladb.bib_mfhd bm3 on l.bib_id = bm3.bib_id
  inner join ucladb.mfhd_master mm3 on bm3.mfhd_id = mm3.mfhd_id
  inner join ucladb.location l3 on mm3.location_id = l3.location_id
  where l3.location_code = 'in' -- Internet
)
select
  lw.mfhd_id
, lw.call_number
, lw.sort_call_number
, (select count(*) from ucladb.mfhd_item where mfhd_id = lw.mfhd_id) as law_items
, ( select subfield from vger_subfields.ucladb_mfhd_subfield
    where record_id = lw.mfhd_id
    and tag = '866a'
    and rownum < 2
  ) as law_f866a
, case
    when sr.bib_id is not null
    then 'Y'
    else 'N'
  end as has_srlf
, sr.srlf_items
, sr.srlf_f866a
, case
    when i.bib_id is not null
    then 'Y'
    else 'N'
  end as has_online
, lw.bib_id
, lw.pub_dates
, case
    -- elink_index not trustworthy?  will investigate further
    -- when exists (select * from ucladb.elink_index where record_id = bm.bib_id and record_type = 'B')
    when exists (select * from vger_subfields.ucladb_bib_subfield where record_id = lw.bib_id and tag like '856%')
    then 'Y'
    else 'N'
  end as has_856
, ( select replace(normal_heading, 'UCOCLC', '') from ucladb.bib_index
    where bib_id = lw.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
  ) as oclc
from law_mfhds lw
left outer join law_srlf sr on lw.bib_id = sr.bib_id
left outer join law_internet i on lw.bib_id = i.bib_id
;
-- created table using the above; took 6.5 hours to run
with d as (select distinct * from vger_report.tmp_rr242) 
select count(*), count(distinct bib_id) as bibs, count(distinct mfhd_id) as hols from d
;
-- 75576	75025	75569

-- 7 pairs of records where law bib is linked to 2 srlf mfhds; data correct
with d as (select distinct * from vger_report.tmp_rr242) 
select * from d
where mfhd_id in (select mfhd_id from d group by mfhd_id having count(*) > 1)
order by mfhd_id
;

-- 74 rows where bib has 856 but no internet holdings
select distinct *
from vger_report.tmp_rr242
where has_online != has_856
order by sort_call_number, law_f866a
;

-- Output for Excel
select distinct *
from vger_report.tmp_rr242
order by sort_call_number, law_f866a
;

-- Clean up, after staff accept data
drop table vger_report.tmp_rr242 purge;
