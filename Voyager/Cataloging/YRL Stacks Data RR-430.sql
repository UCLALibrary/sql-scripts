/*  Selection of MARC data for materials in YRL stacks.
    RR-430
*/

-- Working table: run on server, takes about 50 minutes
create table vger_report.tmp_rr_430 as
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
    --and l3.location_code like 'sr%' -- RR-434
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
from ucladb.location l
inner join ucladb.mfhd_master mm on l.location_id = mm.location_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
where l.location_code in ('yr', 'yr*', 'yr**', 'yr***', 'yrncrc', 'yrpe', 'yrper')
-- Unsuppressed holdings only
and mm.suppress_in_opac = 'N'
-- Must have "call number" - preferably real one, not just text in 852 $h
and mm.normalized_call_no is not null
--order by l.location_code, mm.normalized_call_no
;
create index vger_report.ix_tmp_rr_430_mfhd on vger_report.tmp_rr_430 (mfhd_id);
create index vger_report.ix_tmp_rr_430_oclc on vger_report.tmp_rr_430 (oclc);

select sum(mfhd_count) from ucladb.location l where l.location_code in ('yr', 'yr*', 'yr**', 'yr***', 'yrncrc', 'yrpe', 'yrper');
-- 1550864 20190205
select count(*) from vger_report.tmp_rr_430;
-- 1493255 20190210
select count(distinct oclc) from vger_report.tmp_rr_430;
-- 1479685 20190210

select * from vger_report.tmp_rr_430 where mfhd_id in (
  select mfhd_id from vger_report.tmp_rr_430 group by mfhd_id having count(*) > 1
)
order by mfhd_id;

select * from vger_report.tmp_rr_430
where call_no_type != '0'
--where call_no_type not in ('0', '8')
--where display_call_no like 'SU%'
order by normalized_call_no
;
-- 5033 records, almost all (5026) have call no type = 8

select normalized_call_no, count(*) as num
from vger_report.tmp_rr_430
where call_no_type != '0'
group by normalized_call_no
having count(*) > 50
order by num desc
;

/*  Create supporting table with YRL/SRLF item counts for serials; faster to do this
    once up front than for each row in ~30 queries below.
*/
create table vger_report.tmp_rr_430_serials as
select
  b.bib_id
, b.mfhd_id
, ( select count(*) from ucladb.mfhd_item where mfhd_id = b.mfhd_id ) as yrl_items
, ( select count(*) 
    from ucladb.bib_mfhd bm 
    inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
    inner join ucladb.location l on mm.location_id = l.location_id
    inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
    where bm.bib_id = b.bib_id
    and l.location_code like 'sr%'
) as sr_items    
from vger_report.tmp_rr_430 b
where b.bib_lvl = 's'
;
create index vger_report.ix_tmp_rr_430_serials on vger_report.tmp_rr_430_serials (mfhd_id);

select count(*), count(distinct bib_id) from vger_report.tmp_rr_430_serials;
-- 56905 rows, on 56509 bibs

-- Table for checked OCLC numbers
create table vger_report.tmp_rr_430_checked (
  oclc varchar2(12) not null
, oclc_holdings int not null
, held_by_nrlf char(1) not null
)
;
-- Import data from server: 1275417 rows
-- grep -h [YN]$ done/*.out | sort -u > checked_good.lst
create index vger_report.ix_tmp_rr_430_checked on vger_report.tmp_rr_430_checked (oclc);

-- Clean-up a few zero-left-padded OCLC numbers
update vger_report.tmp_rr_430 set oclc = ltrim(oclc, '0') where oclc like '0%';
update vger_report.tmp_rr_430_checked set oclc = ltrim(oclc, '0') where oclc like '0%';
-- And a lot of space-padded OCLC numbers from API program....
delete from vger_report.tmp_rr_430_checked where trim(oclc) is null;

update vger_report.tmp_rr_430_checked set oclc = trim(oclc) where oclc like '% %';
commit;

-- Did various cleanup; there are 50 left which either trigger errors (bad JSON), or legitimately have 0 holdings.
select count(*) from tmp_rr_430_checked where oclc_holdings = 0;
--delete from vger_report.tmp_rr_430_checked where oclc_holdings = 0;
--commit;

/***********************************************************
  Generate Excel reports
  
  Format / Classification files
  -- Serials: 56905
  -- Mono sets: 54022
  -- Monos (single): who knows... no sheet for O, X
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
, n.held_by_nrlf
, n.oclc_holdings
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
from vger_report.tmp_rr_430 r
--left outer join vger_report.tmp_rr_430_serials s on r.mfhd_id = s.mfhd_id -- only for serials
left outer join vger_report.tmp_rr_430_checked n on r.oclc = n.oclc
where normalized_call_no not in ('SRLF', 'SEE INDIVIDUAL RECORDS FOR CALL NUMBERS', 'SUPPRESSED', 'IN PROCESS')
--and bib_lvl = 's' -- Serials, all
--and bib_lvl = 'm' and (dt_status = 'm' or summ_hlds = 'X') -- Mono sets, all
and bib_lvl = 'm' and (dt_status != 'm' and summ_hlds is null) -- Monos (single), letter by letter, including non-letters for errors
--and normalized_call_no like 'Z%' -- change to each letter for separate export
and not regexp_like(normalized_call_no, '^[A-Z]') -- non-letters for errors
order by normalized_call_no
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
, n.held_by_nrlf
, n.oclc_holdings
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
from vger_report.tmp_rr_430 r
left outer join vger_report.tmp_rr_430_serials s on r.mfhd_id = s.mfhd_id -- only for serials, but have to include on floor-based reports
left outer join vger_report.tmp_rr_430_checked n on r.oclc = n.oclc
where normalized_call_no not in ('SRLF', 'SEE INDIVIDUAL RECORDS FOR CALL NUMBERS', 'SUPPRESSED', 'IN PROCESS')
--and regexp_like(normalized_call_no, '^[A-E]') -- 3rd floor
--and (regexp_like(normalized_call_no, '^[F-O]') or regexp_like(normalized_call_no, '^P ')) --4th floor
and (regexp_like(normalized_call_no, '^P[A-Z]') or regexp_like(normalized_call_no, '^[Q-Z]')) --5th floor
order by normalized_call_no
;

-- Any non mono/serials?
select bib_lvl, count(*) as num
from vger_report.tmp_rr_430
where bib_lvl not in ('m', 's')
group by bib_lvl
order by bib_lvl
;
-- 231

-- Clean up
drop table vger_report.tmp_rr_430 purge;
drop table vger_report.tmp_rr_430_checked purge;
drop table vger_report.tmp_rr_430_serials purge;

-- Compare
-- 9301 in base table have no OCLC number, thus no match
select count(*)
from vger_report.tmp_rr_430 r
where not exists (
  select * 
  from vger_report.tmp_rr_430_checked
  where oclc = r.oclc
)
--and oclc is not null
;

select count(distinct oclc) from vger_report.tmp_rr_430; -- 1481920
select count(distinct oclc) from vger_report.tmp_rr_430_checked; -- 1275417

select * from vger_report.tmp_rr_430_checked where oclc_holdings = 0;
select * from vger_report.tmp_rr_430 where oclc = '992003054';

