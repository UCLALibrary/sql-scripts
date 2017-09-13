/*  African-American newspapers and periodicals, and
    LGBT newspapers and periodicals, for
    DPLA Survey Project on 
    “Building Directories for African American Newspapers and LGBT Newspapers (US states and territories)”
    RR-298

Note: All categories below must be serial titles (Leader/07 = s)

African American newspapers
	Bib record contains a 752 field with “United States” in the subfield $a
	“African Americans” appears in one of the 650 fields in subfield $a

African American periodicals
	Bib record call# (in 050 field or 090 field) begins with “E185.5” in subfield $a
	“African Americans” appears in one of the 650 fields in subfield $a

LGBT newspapers
	Bib record contains a 752 field with “United States” in the subfield $a
	Keyword “Gay*” or “Lesbian*” [truncation] appears in one of the 650 fields in subfield $a

LGBT periodicals
  Byte 008/17 contains “u” [published in the United States]
  Bib record call# (in 050 field or 090 field) begins with these 4 characters “HQ75” in subfield $a
*/

-- Capture base info from BIB_TEXT for 4 categories of record, in one common working table.
-- This is used in later detail queries.
create table vger_report.tmp_rr_298 as
-- African-American newpapers
select distinct
  bt.bib_id
, 'AA' as topic
, 'N' as material
, bt.title_brief
, bt.lccn
, bt.issn
, bt.pub_place
, substr(bt.place_code, 1, 2) as state_code -- bib 008/15-16 only
from ucladb.bib_text bt
-- 752 $a
inner join vger_subfields.ucladb_bib_subfield bs1
  on bt.bib_id = bs1.record_id
  and bs1.tag = '752a'
  and upper(bs1.subfield) like '%UNITED STATES%'
-- 650 $a; bib_index is not subfield-specific
inner join vger_subfields.ucladb_bib_subfield bs2
  on bt.bib_id = bs2.record_id
  and bs2.tag = '650a'
  and upper(bs2.subfield) like '%AFRICAN AMERICANS%'
where bt.bib_format like '%s'
-- 139
union 
-- African-American periodicals
select distinct
  bt.bib_id 
, 'AA' as topic
, 'P' as material
, bt.title_brief
, bt.lccn
, bt.issn
, bt.pub_place
, substr(bt.place_code, 1, 2) as state_code -- bib 008/15-16 only
from ucladb.bib_text bt
-- 050/090 $a
inner join vger_subfields.ucladb_bib_subfield bs1
  on bt.bib_id = bs1.record_id
  and bs1.tag in ('050a', '090a')
  and bs1.subfield like 'E185.5%'
-- 650 $a; bib_index is not subfield-specific
inner join vger_subfields.ucladb_bib_subfield bs2
  on bt.bib_id = bs2.record_id
  and bs2.tag = '650a'
  and upper(bs2.subfield) like '%AFRICAN AMERICANS%'
where bt.bib_format like '%s'
-- 138
union
-- LGBT newpapers
select distinct
  bt.bib_id 
, 'LG' as topic
, 'N' as material
, bt.title_brief
, bt.lccn
, bt.issn
, bt.pub_place
, substr(bt.place_code, 1, 2) as state_code -- bib 008/15-16 only
from ucladb.bib_text bt
-- 752 $a
inner join vger_subfields.ucladb_bib_subfield bs1
  on bt.bib_id = bs1.record_id
  and bs1.tag = '752a'
  and upper(bs1.subfield) like '%UNITED STATES%'
-- 650 $a; bib_index is not subfield-specific
inner join vger_subfields.ucladb_bib_subfield bs2
  on bt.bib_id = bs2.record_id
  and bs2.tag = '650a'
  and (upper(bs2.subfield) like '%GAY%' or upper(bs2.subfield) like '%LESBIAN%')
where bt.bib_format like '%s'
-- 14
union
-- LGBT periodicals
select distinct
  bt.bib_id 
, 'LG' as topic
, 'P' as material
, bt.title_brief
, bt.lccn
, bt.issn
, bt.pub_place
, substr(bt.place_code, 1, 2) as state_code -- bib 008/15-16 only
from ucladb.bib_text bt
-- 050/090 $a
inner join vger_subfields.ucladb_bib_subfield bs1
  on bt.bib_id = bs1.record_id
  and bs1.tag in ('050a', '090a')
  and bs1.subfield like 'HQ75%'
where bt.bib_format like '%s'
-- 008/17 = 'u' (united states)
and substr(bt.field_008, 18, 1) = 'u' -- oracle is 1-based, marc is 0-based
-- 107
;
create index vger_report.ix_tmp_rr_298 on vger_report.tmp_rr_298 (bib_id, topic, material);

-- spot-check records before moving on
select *
from vger_report.tmp_rr_298
order by topic, material, title_brief
;

select topic, material, count(*) as num
from vger_report.tmp_rr_298
group by topic, material
order by topic, material;


-- Detail queries
with all_data as (
  select distinct -- some titles are both periodical and newspaper
    title_brief
  , t.bib_id -- for debugging
  --, topic -- for separate output
  --, material -- for newspaper vs periodical distinction; needed?
  , lccn
  , issn
  , (select replace(normal_heading, 'UCOCLC', '') from ucladb.bib_index where bib_id = t.bib_id and index_code = '0350' and normal_heading like 'UCOCLC%' and rownum < 2) as oclc_number
  , pub_place
  , state_code
  , (select subfield from vger_subfields.ucladb_bib_subfield where record_id = t.bib_id and tag = '752d' and rownum < 2) as f752d
  , (select subfield from vger_subfields.ucladb_bib_subfield where record_id = t.bib_id and tag = '752b' and rownum < 2) as f752b
  , (select subfield from vger_subfields.ucladb_bib_subfield where record_id = t.bib_id and tag = '310a' and rownum < 2) as f310a
  , case when exists (
      select * from vger_subfields.ucladb_bib_subfield where record_id = t.bib_id and tag in ('338a', '530a', '533a') and upper(subfield) like '%MICROFILM%'
    )
    then 'yes' else null end
    as has_microfilm_bib
  , vger_subfields.GetSubfields(t.bib_id, '8563') as f8563_all
  , bm.mfhd_id
  , case when exists (
      select * from vger_subfields.ucladb_mfhd_subfield
      where record_id = bm.mfhd_id
      and (   
            ( tag = '007' and subfield like 'h%')
        or  ( tag = '852k' and (upper(subfield) like '%MICROFICHE%' or upper(subfield) like '%MICROFILM%') )
      )
    )
    then 'yes'
    end as has_mf_holdings
  , case when exists (
      select * from vger_subfields.ucladb_mfhd_subfield
      where record_id = bm.mfhd_id
      and tag = '852b'
      and subfield = 'in'
    )
    then 'yes'
    end as has_internet_holdings
  , ms.subfield as f866a
  from vger_report.tmp_rr_298 t
  inner join ucladb.bib_mfhd bm on t.bib_id = bm.bib_id
  inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join vger_subfields.ucladb_mfhd_subfield ms on bm.mfhd_id = ms.record_id and ms.tag = '866a'
  where mm.suppress_in_opac = 'N'
  and t.topic = 'LG' -- change this for AA/LG output
)
select
  'UCLA' as collecting_institution
, bib_id -- TESTING
, mfhd_id -- TESTING
, vger_support.unifix(title_brief) as title
, lccn
, issn
, coalesce(f752d, vger_support.unifix(pub_place)) as city_of_publication
, coalesce(f752b, to_nchar(state_code)) as state_of_publication
, f310a as frequency_of_publication
, case when coalesce(has_internet_holdings, has_mf_holdings) is null
  then 'yes'
  end as format_print
, case when coalesce(has_internet_holdings, has_mf_holdings) is null
  then f866a
  end as print_range_description
, has_microfilm_bib as format_microfilm
, case when has_mf_holdings is not null
  then f866a
  end as microfilm_range_description
, has_internet_holdings as format_digitized
, case when has_internet_holdings is not null
  then f8563_all
  end as digitized_range_description
, 'John Riemer' as record_source
, 'UCLA' as record_source_institution
, 'Los Angeles' as record_source_city
, 'California' as record_source_state
, 'jriemer@library.ucla.edu' as record_source_email
, oclc_number
from all_data
order by bib_id
;
-- AA: 260 bibs, 415 mfhds; 425 rows
-- LG: 111 bibs, 181 mfhds; 195 rows


-- Clean up
drop table vger_report.tmp_rr_298 purge;