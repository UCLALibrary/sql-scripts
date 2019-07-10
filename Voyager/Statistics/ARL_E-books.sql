-- Working table of all bibs we consider to be electronic books for ARL stats, per https://docs.library.ucla.edu/x/ugDc
-- Used starting 2012/2013, per Roxanne Peck; see Footprints 29910

-- Change end_date to start of fiscal year after the one you want (e.g., 20080701 for 2007/2008)
define end_date = '20190701';

create table vger_report.tmp_ebook_bibs as
select distinct -- a few bibs have multiple 'in' holdings.......
  bt.bib_id
from ucladb.bib_text bt
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where l.location_code = 'in'
and mm.suppress_in_opac = 'N'
and ( bt.bib_format = 'am'
  or  ( bt.bib_format like 'e%' -- cartographic materials
        and substr(bt.field_008, 26, 1) = 'e' -- 008/25: atlases
      )
)
and bt.bib_id <= (
  select max(bib_id)
  from ucladb.bib_history
  where action_date < to_date('&end_date', 'YYYYMMDD')
  and action_type_id = 1
);

create index vger_report.ix_tmp_ebook_bibs on vger_report.tmp_ebook_bibs(bib_id);

select count(*) from vger_report.tmp_ebook_bibs;
-- 666975 20130325 for 2011/2012
-- 739385 20130701 for 2012/2013
-- 785828 20140702 for 2013/2014
-- 830366 20150702 for 2014/2015
-- 868697 20160718 for 2015/2016
-- 913676 20170705 for 2016/2017
-- 1034386 20180705 for 2017/2018
-- 1121118 20190702 for 20182019

-- Working table with all 856 fields for tmp_ebook_bibs
-- Takes about 2 minutes to create
create table vger_report.tmp_ebook_urls as
select distinct
  b.bib_id
, bs.field_seq
, bs.indicators
from vger_report.tmp_ebook_bibs b
inner join vger_subfields.ucladb_bib_subfield bs
  on b.bib_id = bs.record_id
  and bs.tag like '856%'
;
create index vger_report.ix_tmp_ebook_urls on vger_report.tmp_ebook_urls(indicators, bib_id);

select count(distinct bib_id) from vger_report.tmp_ebook_urls;
-- 739303 20130701 for 2012/2013 (a few bibs don't have 856 $u....)
-- 785783 20140702 for 2013/2014
-- 830284 20150702 for 2014/2015
-- 867669 20160718 for 2015/2016
-- 912984 20170705 for 2016/2017
-- 1034315 20180705 for 2017/2018
-- 1121001 20190702 for 2018/2019

/*********
  Start with working tables, include / exclude based on various criteria
*********/
with d as (
  -- Group 1: 856 40: Keep all
  select distinct bib_id, 1 as grp
    from vger_report.tmp_ebook_urls
    where indicators = '40'
  union all
  -- Group 2: 856 4_ and no other 856: Keep only if 910 $a contains netLibrary
  select distinct bib_id, 2 as grp
    from vger_report.tmp_ebook_urls u
    where indicators = '4 '
    and not exists (
      select * from vger_report.tmp_ebook_urls
      where bib_id = u.bib_id
      and indicators != '4 '
    )
    and exists (
      select * from vger_subfields.ucladb_bib_subfield
      where record_id = u.bib_id
      and tag = '910a'
      and upper(subfield) like '%NETLIBRARY%'
    )
  minus -- MINUS here, not UNION ALL!
  -- Group 3: 856 __ and no other 856: Keep none
  select distinct bib_id, 3 as grp
    from vger_report.tmp_ebook_urls u
    where indicators = '  '
    and not exists (
      select * from vger_report.tmp_ebook_urls
      where bib_id = u.bib_id
      and indicators != '  '
    )
  union all
  -- Group 4: 856 41 and no 856 40: Keep only if no $3 beginning with: Table of Contents
  select distinct bib_id, 4 as grp
    from vger_report.tmp_ebook_urls u
    where indicators = '41'
    and not exists (
      select * from vger_report.tmp_ebook_urls
      where bib_id = u.bib_id
      and indicators = '40'
    )
    and not exists (
      select * from vger_subfields.ucladb_bib_subfield
      where record_id = u.bib_id
      and field_seq = u.field_seq
      and tag = '8563'
      and upper(subfield) like 'TABLE OF CONTENTS%'
    )
  union all
  -- Group 5: 856 42 and no 856 40 or 41: Keep only if 049 $a CLYY
  select distinct bib_id, 5 as grp
    from vger_report.tmp_ebook_urls u
    where indicators = '42'
    and not exists (
      select * from vger_report.tmp_ebook_urls
      where bib_id = u.bib_id
      and indicators in ('40', '41')
    )
    and exists (
      select * from vger_subfields.ucladb_bib_subfield
      where record_id = u.bib_id
      and tag = '049a'
      and subfield = 'CLYY'
    )
)
select count(distinct bib_id) as bibs
from d
;
-- REPORT THIS FIGURE ANNUALLY, on the E-Books sheet in the UCOP Voyager stats Excel file.
-- 2013-03-25: 664221 before minus, 663085 after.  664221-663085 = 1136, count of group 3.
-- 735257 20130701 for 2012/2013.  This is the figure reported on E-books sheet in file sent to Leslie.  No need to report e-monos & e-atlases separately per Leslie.
-- 781437 20140702 for 2013/2014.
-- 825532 20150702 for 2014/2015.
-- 862728 20160718 for 2015/2016
-- 907841 20170705 for 2016/2017
-- 1028914 20180705 for 2017/2018
-- 1115519 20190702 for 2018/2019

/***** Individual queries for testing / clean-up *****/

-- "Internet" bibs with no 856 fields... sent to mono-maint for cleanup
with bibs as (
  select eb.bib_id from vger_report.tmp_ebook_bibs eb
  where not exists (select * from vger_report.tmp_ebook_urls where bib_id = eb.bib_id)
)
select distinct
  b.bib_id
, l.location_code
from bibs b
inner join ucladb.bib_mfhd bm on b.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where l.location_code != 'in'
order by b.bib_id, l.location_code
;

-- Group 1: 856 40: Keep all
select count(distinct bib_id) 
from vger_report.tmp_ebook_urls
where indicators = '40'
;
-- 613100 bibs

-- Group 2: 856 4_ and no other 856: Keep only if 910 $a contains netLibrary
select count(distinct bib_id) 
from vger_report.tmp_ebook_urls u
where indicators = '4 ' --2625
and not exists (
  select * from vger_report.tmp_ebook_urls
  where bib_id = u.bib_id
  and indicators != '4 '
)
and exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = u.bib_id
  and tag = '910a'
  and upper(subfield) like '%NETLIBRARY%'
)
;
-- 401 bibs

-- Group 3: 856 __ and no other 856: Keep none
select bib_id -- count(distinct bib_id) 
from vger_report.tmp_ebook_urls u
where indicators = '  '
and not exists (
  select * from vger_report.tmp_ebook_urls
  where bib_id = u.bib_id
  and indicators != '  '
)
;
-- 1136 bibs

-- Group 4: 856 41 and no 856 40: Keep only if no $3 beginning with: Table of Contents
select count(distinct bib_id) 
from vger_report.tmp_ebook_urls u
where indicators = '41'
and not exists (
  select * from vger_report.tmp_ebook_urls
  where bib_id = u.bib_id
  and indicators = '40'
) -- 49946
and not exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = u.bib_id
  and field_seq = u.field_seq
  and tag = '8563'
  and upper(subfield) like 'TABLE OF CONTENTS%'
)
;
-- 49392 bibs

-- Group 5: 856 42 and no 856 40 or 41: Keep only if 049 $a CLYY
select count(distinct bib_id) 
from vger_report.tmp_ebook_urls u
where indicators = '42'
and not exists (
  select * from vger_report.tmp_ebook_urls
  where bib_id = u.bib_id
  and indicators in ('40', '41')
) -- 495
and exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = u.bib_id
  and tag = '049a'
  and subfield = 'CLYY'
)
;
-- 192 bibs
/***** Individual queries for testing / clean-up *****/

-- All done, remove the working tables
drop table vger_report.tmp_ebook_urls purge;
drop table vger_report.tmp_ebook_bibs purge;

