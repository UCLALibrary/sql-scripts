/*  Another extension of RR-430 and RR-434.

    RR-501 and RR-509.
*/

-- Import floor-based data from RR-434 files (converted to CSV, most columns ignored).
-- This is to get NRLF/OCLC holdings so that doesn't have to be checked again: stale but OK.
create table vger_report.tmp_rr434_import (
  oclc varchar2(12)
, bib_id int
, held_by_nrlf char(1)
, oclc_holdings int
)
;
create index vger_report.ix_tmp_rr434_import on vger_report.tmp_rr434_import (bib_id);

select count(*) from vger_report.tmp_rr434_import;
-- 1519033

/*****************************************************************************/
-- Working table: run on server, takes about 50 minutes
create table vger_report.tmp_rr_501 as
select
  ( select replace(normal_heading, 'UCOCLC') 
    from ucladb.bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
) as oclc
, bt.bib_id
, 'https://catalog.library.ucla.edu/vwebv/holdingsInfo?bibId=' || bt.bib_id as permalink
, mm.mfhd_id
, l.location_code
, mm.call_no_type
, mm.normalized_call_no
, mm.display_call_no
, ( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from ucladb.bib_location bl
    inner join ucladb.location l2 on bl.location_id = l2.location_id
    where bl.bib_id = bt.bib_id
    --and l2.location_code != l.location_code
    and l2.location_code not in ('yr', 'yr*', 'yr**', 'yr***', 'yrncrc', 'yrpe', 'yrper')
    and l2.location_code not like 'sr%'
) as other_locs
, ( select listagg(l3.location_code, ', ') within group (order by l3.location_code)
    from ucladb.bib_location bl2
    inner join ucladb.location l3 on bl2.location_id = l3.location_id
    where bl2.bib_id = bt.bib_id
    --and l2.location_code != l.location_code
    and l3.location_code in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4', 'srbuo')
) as srlf_locs
, substr(bt.bib_format, 2, 1) as bib_lvl
, substr(bt.bib_format, 1, 1) as record_type
, substr(bt.field_008, 29, 1) as govt_pub -- 008/28
, bt.place_code
, bt.language
, bt.date_type_status as dt_status
, bt.begin_pub_date as date1
, bt.end_pub_date as date2
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(ucladb.GetBibTag(bt.bib_id, '260 264')) as pub_info
, vger_subfields.GetFirstSubfield(bt.bib_id, '300a') as physical_extent
, case when exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and regexp_like(tag, '^86[678]'))
    then 'X'
    else null
  end as summ_hlds
, vger_subfields.GetSubfields(bt.bib_id, '776i,776a,776t,776w') as other_form
, ucladb.GetAllBibTag(bt.bib_id, '856', 2) as urls
-- To be added later
, cast(null as int) as oclc_holdings
, cast(null as char(1)) as held_by_nrlf
, 0 as circ_trans
from ucladb.location l
inner join ucladb.mfhd_master mm on l.location_id = mm.location_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
where l.location_code in ('yr', 'yr*', 'yr**', 'yr***', 'yrncrc', 'yrpe', 'yrper')
-- Unsuppressed holdings only
and mm.suppress_in_opac = 'N'
-- Must have "call number" - preferably real one, not just text in 852 $h
and mm.normalized_call_no is not null
;

create index vger_report.ix_tmp_rr501 on vger_report.tmp_rr_501 (bib_id);

select count(*), count(distinct bib_id), count(distinct mfhd_id) from vger_report.tmp_rr_501;
-- 1507246

select * from vger_report.tmp_rr_501 where bib_id = 2202;
select distinct * from vger_report.tmp_rr434_import where bib_id = 2202;

-- Add historical NRLF/OCLC holdings data from RR-434 project where present.
-- Except for serials, for which we'll get fresh NRLF/OCLC data...

-- Clear some duplicates
update vger_report.tmp_rr434_import
  set held_by_nrlf = null
, oclc_holdings = null
where (bib_id, oclc) in (
  select bib_id, oclc
  from vger_report.tmp_rr434_import
  group by bib_id, oclc
  having count(*) > 1
)
;

merge into vger_report.tmp_rr_501 t1
using (
  select distinct bib_id, oclc, oclc_holdings, held_by_nrlf 
  from vger_report.tmp_rr434_import
) t2
on (t1.bib_id = t2.bib_id and t1.oclc = t2.oclc)
when matched then update set
  t1.oclc_holdings = t2.oclc_holdings
, t1.held_by_nrlf = t2.held_by_nrlf
;

update vger_report.tmp_rr_501 set held_by_nrlf = null, oclc_holdings = null where bib_lvl = 's';

commit;

-- Get list of records lacking NRLF/OCLC data
select distinct oclc
from vger_report.tmp_rr_501
where oclc_holdings is null
or held_by_nrlf is null
order by oclc
;
-- 103135 rows

-- Create empty table for NRLF/OCLC data
create table vger_report.tmp_rr_501_checked as
select oclc, held_by_nrlf, oclc_holdings from vger_report.tmp_rr_501 where 1=0
;
create index vger_report.ix_tmp_rr_501_checked on vger_report.tmp_rr_501_checked (oclc);

-- Clean up imported data, which got padded somehow
update vger_report.tmp_rr_501_checked set oclc = trim(oclc);
commit;

-- Merge new NRLF/OCLC data into working table
merge into vger_report.tmp_rr_501 t1
using (
  select *
  from vger_report.tmp_rr_501_checked
) t2
on (t1.oclc = t2.oclc)
when matched then update set
  t1.oclc_holdings = t2.oclc_holdings
, t1.held_by_nrlf = t2.held_by_nrlf
;
-- 106819 rows, due to dup OCLC numbers in YRL data
commit;

-- Add circ transactions by holdings record
merge into vger_report.tmp_rr_501 t1
using (
  select mfhd_id, count(*) as cnt
  from ucladb.circcharges_vw
  group by mfhd_id
) t2
on (t1.mfhd_id = t2.mfhd_id)
when matched then update set
  t1.circ_trans = t2.cnt
;
commit;

/*  Create supporting table with YRL/SRLF item counts for serials; faster to do this
    once up front than for each row in ~30 queries below.
*/
create table vger_report.tmp_rr_501_serials as
select
  b.bib_id
, b.mfhd_id
, ( select count(*) from ucladb.mfhd_item where mfhd_id = b.mfhd_id ) as yrl_items
, ( select count(*) 
    from ucladb.bib_mfhd bm 
    inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
    inner join ucladb.location l on mm.location_id = l.location_id
    inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
    inner join ucladb.item i on mi.item_id = i.item_id
    inner join ucladb.item_type itp on i.item_type_id = itp.item_type_id
    where bm.bib_id = b.bib_id
    and l.location_code in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4', 'srbuo')
    and (   itp.item_type_name in ('SRLF Journals', 'WEST Bronze', 'WEST Gold', 'WEST Silver')
        or  (itp.item_type_name = 'Building Use' and mi.freetext is null)  
    )
) as sr_items    
from vger_report.tmp_rr_501 b
where b.bib_lvl = 's'
;
-- 56360 serials


/***********************************************************
  Generate Excel reports
  Format / Classification files
***********************************************************/
select
  r.oclc
, r.bib_id
, r.permalink
, r.mfhd_id
, r.location_code
--, s.yrl_items -- only for serials
, r.call_no_type
, r.normalized_call_no
, r.display_call_no
, r.other_locs
, r.srlf_locs
--, s.sr_items as srlf_items -- only for serials
, r.held_by_nrlf
, r.oclc_holdings
, r.circ_trans
, r.bib_lvl
, r.record_type
, r.govt_pub
, r.place_code
, r.language
, r.dt_status
, r.date1
, r.date2
, r.author
, r.title
, r.pub_info
, r.physical_extent
, r.summ_hlds
, r.other_form
, r.urls
from vger_report.tmp_rr_501 r
--left outer join vger_report.tmp_rr_501_serials s on r.mfhd_id = s.mfhd_id -- only for serials
where r.normalized_call_no not in ('SRLF', 'SEE INDIVIDUAL RECORDS FOR CALL NUMBERS', 'SUPPRESSED', 'IN PROCESS')
--and r.bib_lvl = 's' -- Serials, all
--and r.bib_lvl = 'm' and (r.dt_status = 'm' or r.summ_hlds = 'X') -- Mono sets, all
and r.bib_lvl = 'm' and (r.dt_status != 'm' and r.summ_hlds is null) -- Monos (single), letter by letter, including non-letters for errors
and r.normalized_call_no like 'O%' -- change to each letter for separate export
--and not regexp_like(r.normalized_call_no, '^[A-Z]') -- non-letters for errors
order by r.normalized_call_no
;

-- By YRL floors: 3rd (A-E), 4th (F-P), 5th (PA-Z)
select
  r.oclc
, r.bib_id
, r.permalink
, r.mfhd_id
, r.location_code
, s.yrl_items -- only for serials
, r.call_no_type
, r.normalized_call_no
, r.display_call_no
, r.other_locs
, r.srlf_locs
, s.sr_items as srlf_items -- only for serials
, r.held_by_nrlf
, r.oclc_holdings
, r.circ_trans
, r.bib_lvl
, r.record_type
, r.govt_pub
, r.place_code
, r.language
, r.dt_status
, r.date1
, r.date2
, r.author
, r.title
, r.pub_info
, r.physical_extent
, r.summ_hlds
, r.other_form
, r.urls
from vger_report.tmp_rr_501 r
left outer join vger_report.tmp_rr_501_serials s on r.mfhd_id = s.mfhd_id -- only for serials, but have to include on floor-based reports
where r.normalized_call_no not in ('SRLF', 'SEE INDIVIDUAL RECORDS FOR CALL NUMBERS', 'SUPPRESSED', 'IN PROCESS')
--and regexp_like(r.normalized_call_no, '^[A-E]') -- 3rd floor
--and (regexp_like(r.normalized_call_no, '^[F-O]') or regexp_like(r.normalized_call_no, '^P ')) --4th floor
and (regexp_like(r.normalized_call_no, '^P[A-Z]') or regexp_like(r.normalized_call_no, '^[Q-Z]')) --5th floor
order by r.normalized_call_no
;



-- Clean up
--drop table vger_report.tmp_rr434_import purge;
--drop table vger_report.tmp_rr_501_checked purge;
--drop table vger_report.tmp_rr_501_serials purge;
--drop table vger_report.tmp_rr_501 purge;

