/*  Voyager data for HathiTrust ETAS titles, including circulations during 2017-2019.
    RR-649
*/

-- 2637696 in overlap table; 2065729 ETAS (deny/null), 571967 PD (allow)

-- Temporary table with circulation counts by bib
drop table vger_report.tmp_bib_circs purge;
create table vger_report.tmp_bib_circs as
select bib_id, count(*) as circs
from ucladb.circcharges_vw
where charge_date_only between to_date('20170101', 'YYYYMMDD') and to_date('20200101', 'YYYYMMDD') -- during calendar 2017-2019
and patron_group_code != 'GBS'
group by bib_id
;
create index vger_report.ix_tmp_bib_circs on vger_report.tmp_bib_circs (bib_id, circs);
grant select on vger_report.tmp_bib_circs to ucla_preaddb;

-- Main query
-- Store in temp table to work around Excel row limits - will need multiple export files
drop table vger_report.tmp_rr_649 purge;
create table vger_report.tmp_rr_649 as 
select 
  h.oclc_number
, h.bib_id
, 'https://catalog.library.ucla.edu/vwebv/holdingsInfo?bibId=' || h.bib_id as permalink
, ( select trim(substr(min(call_no_type || normalized_call_no), 2, 15))
    from ucladb.mfhd_master
    where mfhd_id in (select mfhd_id from ucladb.bib_mfhd where bib_id = h.bib_id)
) as cn_stub
, bt.place_code
, bt.language
, bt.date_type_status as dttp
, bt.begin_pub_date
, bt.end_pub_date
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.imprint) as imprint -- 1st 260/264
, c.circs
from vger_report.hathi_overlap h
inner join ucladb.bib_text bt on h.bib_id = bt.bib_id
left outer join vger_report.tmp_bib_circs c on h.bib_id = c.bib_id
where (h.access_lvl = 'deny' or h.access_lvl is null) -- several hundred have no access info from HT, so we must assume in copyright
and bt.bib_format = 'am' -- print monographs only
--order by h.bib_id
;
create index vger_report.ix_tmp_rr_649 on vger_report.tmp_rr_649 (cn_stub);
select count(*) from vger_report.tmp_rr_649;
-- 1913120 rows

-- 1913120 rows: 2065729 in hathi_overlap, 2044976 match bib_text, 1913120 are print monos
select count(*) 
from vger_report.hathi_overlap h
inner join ucladb.bib_text bt on h.bib_id = bt.bib_id
where (h.access_lvl = 'deny' or h.access_lvl is null) -- several hundred have no access info from HT, so we must assume in copyright
and bt.bib_format = 'am' -- print monographs only
;

-- Export data to Excel in 2 batches
select *
from vger_report.tmp_rr_649
--where cn_stub is null or not regexp_like(cn_stub, '^[A-Z]') or regexp_like(cn_stub, '^[A-H]') -- 993233
where regexp_like(cn_stub, '^[I-Z]') -- 919887
order by cn_stub
;


select count(*) from vger_report.tmp_rr_649 where cn_stub is null;