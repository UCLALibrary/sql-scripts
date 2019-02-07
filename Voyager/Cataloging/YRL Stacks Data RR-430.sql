/*  Selection of MARC data for materials in YRL stacks.
    RR-430
*/

-- Working table
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
    and l3.location_code like 'sr%'
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

select sum(mfhd_count) from ucladb.location l where l.location_code in ('yr', 'yr*', 'yr**', 'yr***', 'yrncrc', 'yrpe', 'yrper');
-- 1550864 20190205
select count(*) from vger_report.tmp_rr_430;
-- 1492093 20190206

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

-- Format / Classification files
-- Serials: 55291
-- Mono sets: 53560
-- Monos (single): who knows... no sheet for O, X
select *
from vger_report.tmp_rr_430
--where bib_lvl = 's'
--where bib_lvl = 'm' and (dt_status = 'm' or summ_hlds = 'X')
where bib_lvl = 'm' and (dt_status != 'm' and summ_hlds is null)
and normalized_call_no not in ('SRLF', 'SEE INDIVIDUAL RECORDS FOR CALL NUMBERS', 'SUPPRESSED', 'IN PROCESS')
--and normalized_call_no like 'Z%'
and not regexp_like(normalized_call_no, '^[A-Z]')
order by normalized_call_no
;

-- By YRL floors: 3rd (A-E), 4th (F-P), 5th (PA-Z)
select *
from vger_report.tmp_rr_430
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
