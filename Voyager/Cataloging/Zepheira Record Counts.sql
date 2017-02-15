/*  Various record counts for possible Zepheira projects.
    Keeping SQL in case this leads to extraction requests.
    https://jira.library.ucla.edu/browse/VBT-767 (initial counts)
    https://jira.library.ucla.edu/browse/VBT-771 (extraction)
*/

-- 0) Create working table to accumulate bib ids from the queries below, for unified extract
create table vger_report.tmp_VBT_771 (
  bib_id int not null
)
;
create index vger_report.ix_tmp_VBT_771 on vger_report.tmp_VBT_771 (bib_id);

-- 1) bibliographic records with the Leader/Bib Level (07) = m (monograph) and an associated holdings record with 852 $b beginning with yrsp
insert into vger_report.tmp_VBT_771
select
  --count(distinct bt.bib_id) as bibs
  distinct bt.bib_id
from ucladb.bib_text bt
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where l.location_code like 'yrsp%'
and bt.bib_format like '_m'
;
-- 243126 2017-02-07
-- 243303 2017-02-14

-- 2) bibliographic records with Leader/Type of Record (06) = e (printed cartographic material) and a 6XX field containing $v Maps.
insert into vger_report.tmp_VBT_771
select
  --count(distinct bt.bib_id) as bibs
  distinct bt.bib_id
from ucladb.bib_text bt
where bt.bib_format like 'e%'
and exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bt.bib_id
  and tag like '6__v'
  and subfield in ('Maps.', 'Maps')
)
;
-- 522 Maps 35263 Maps. 2017-02-07
-- 35793 combined Maps/Maps. 2017-02-14

-- 3) bibliographic records with the Leader/Bib Level (07) = m AND (651 $a containing $a "Los Angeles (Calif.)" OR a 650 containing "$z California $z Los Angeles")
insert into vger_report.tmp_VBT_771
select
  --count(distinct bt.bib_id) as bibs
  distinct bt.bib_id
from ucladb.bib_text bt
where bt.bib_format like '_m'
and 
( exists 
    (
      select * 
      from vger_subfields.ucladb_bib_subfield
      where record_id = bt.bib_id
      and tag = '651a'
      and subfield = 'Los Angeles (Calif.)'
    )
  or exists
    (
      select * 
      from vger_subfields.ucladb_bib_subfield bs1
      where bs1.record_id = bt.bib_id
      and bs1.tag = '650z'
      and bs1.subfield = 'California'
      and exists (
        select *
        from vger_subfields.ucladb_bib_subfield bs2
        where bs2.record_id = bs1.record_id
        and bs2.field_seq = bs1.field_seq
        and bs2.subfield_seq = bs1.subfield_seq + 1
        and bs2.subfield = 'Los Angeles'
      )
    ) -- end of OR 
) -- end of compound AND
;
-- 6187 2017-02-07
-- 6191 2017-02-14

-- 4) bibliographic records with the Leader/Bib Level (07) = s (serial) and a 245 $a containing "Los Angeles"
insert into vger_report.tmp_VBT_771
select
  --count(distinct bt.bib_id) as bibs
  distinct bt.bib_id
from ucladb.bib_text bt
where bt.bib_format like '_s'
and exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bt.bib_id
  and tag in ('245a', '246a', '247a', '740a')
  and subfield like '%Los Angeles%'
)
;
-- 767 2017-02-07, using just 245 $a from VBT-767
-- 1061 2017-02-14, using broader spec from VBT-771

-- Save everything!
commit;

-- counts
select count(*) as all_bibs, count(distinct bib_id) as bibs from vger_report.tmp_VBT_771;
-- 286348 all,	284039 distinct 2017-02-14

-- Extract records on server via query and Pmarcexport 

-- Clean up after extract
drop table vger_report.tmp_VBT_771 purge;
