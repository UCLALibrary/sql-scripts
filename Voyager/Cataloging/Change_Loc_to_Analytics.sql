/*  Attempted fix for changelocs batchcat program, which finds records which should be
    in Analytics locs (no items, certain locations and data in 852 $h $i) and
    changes their locations.
    
    Query has always been slow (30-60 minutes...) but now is taking many hours or never finishing.
    
    For now, create a temporary table and point the program to it.
    2014-12-06 akohler.
*/

-- Get the data for all records which *potentially* need changing, based on first level of criteria
drop table vger_report.tmp_change_to_analytics purge;
create table vger_report.tmp_change_to_analytics as
with mfhds as (
  select 
    mm.mfhd_id
  , l.location_code as old_loc
  , case 
      when l.location_code in ('ar', 'bi', 'cl', 'mg', 'mu', 'sg', 'sm', 'yr') then l.location_code || 'an'
      when l.location_code in ('ea', 'ea*', 'eaharv') then 'eaan'
      when l.location_code in ('scbjnl', 'scbook', 'scper') then 'scan'
    end as new_loc
  from ucladb.mfhd_master mm
  inner join ucladb.location l on mm.location_id = l.location_id
  where mm.record_type in ('x', 'v')
  and l.location_code in ('ar', 'bi', 'cl', 'ea', 'ea*', 'eaharv', 'mg', 'mu', 'scbjnl', 'scbook', 'scper', 'sg', 'sm', 'yr')
  and not exists (select * from ucladb.mfhd_item where mfhd_id = mm.mfhd_id)
)
, with_sfds as (
  select
    m.mfhd_id
  , m.old_loc
  , m.new_loc
  , substr(s852h.subfield, 1, 30) as s852h
  , substr(s852i.subfield, 1, 30) as s852i
  from mfhds m
  inner join vger_subfields.ucladb_mfhd_subfield s852h
    on m.mfhd_id = s852h.record_id
    and s852h.tag = '852h'
  left join vger_subfields.ucladb_mfhd_subfield s852i
    on m.mfhd_id = s852i.record_id
    and s852i.tag = '852i'
)
select * from with_sfds
;
-- 42685

-- Create a view which finds *only* the data for records which need changing, 
-- now that we have a manageable set of records.
create or replace view vger_report.change_to_analytics as
select *
from vger_report.tmp_change_to_analytics
where (
  old_loc in ('ar', 'bi', 'cl', 'mg', 'scbjnl', 'scbook', 'scper', 'sg', 'sm', 'yr')
  and (
        s852i like '%no.%'
    or  s852i like '% no %'
    or  s852i like '%pt.%'
    or  s852i like '% pt %'
    or  s852i like '%v.%'
    or  s852i like '% v %'
  )
)
or (
  old_loc in ('ea', 'ea*', 'eaharv')
  -- ea: check 852 $h and $i
  and (
        s852h like '%no.%'
    or  s852h like '% no %'
    or  s852h like '%pt.%'
    or  s852h like '% pt %'
    or  s852h like '%v.%'
    or  s852h like '% v %'
    or  s852i like '%no.%'
    or  s852i like '% no %'
    or  s852i like '%pt.%'
    or  s852i like '% pt %'
    or  s852i like '%v.%'
    or  s852i like '% v %'
  )
)
or (
  old_loc in ('mu')
  and (
        s852i like '%pt.%'
    or  s852i like '% pt %'
    or  s852i like '%v.%'
    or  s852i like '% v %'
  )
)
;

-- Allow the batchcat program to access the view
grant select on vger_report.change_to_analytics to ucla_preaddb;
