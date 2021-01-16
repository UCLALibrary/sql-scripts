/*  Bibs with multiple 776 fields: 2 reports, based on holdings.
    SILSLA-57
*/

with multiple776 as (
  select distinct
    bs.record_id as bib_id
  from vger_subfields.ucladb_bib_subfield bs
  where bs.tag like '776%'
  and exists (
    select * from vger_subfields.ucladb_bib_subfield
    where record_id = bs.record_id
    and tag like '776%'
    and field_seq != bs.field_seq
  )
)
, mfhds as (
  select 
    b.bib_id
  , mm.mfhd_id
  , l.location_code
  from multiple776 b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
)
, internet_only as (
  select *
  from mfhds m
  where location_code = 'in'
  and not exists (
    select * from mfhds
    where bib_id = m.bib_id
    and location_code != 'in'
  )
)
-- Report 1: multiple 776, with at least 1 non-internet holdings
--select * from mfhds minus select * from internet_only order by 1, 3, 2 --bib_id, location_code, mfhd_id
-- OR --
-- Report 2: multiple 776, with only internet holdings
--select * from internet_only order by bib_id, location_code, mfhd_id
-- OR --
-- Neither: no holdings attached to these
--select * from multiple776 b where not exists (select * from mfhds where bib_id = b.bib_id) order by bib_id
;
-- 72144 bibs: 72131 have mfhds; 27142 bibs (45256 bib/mfhd) are not internet-only; 44989 bibs are internet only
