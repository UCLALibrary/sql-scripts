/*  Temporarily suppress part of Management collection during move.
    See VBT-307 for details.
    Work as UCLADB for direct SQL manipulation of records.
*/

/**** Phase 1: Sat Nov 15 2014 ****/

-- Save the mfhd ids of records which are already suppressed, 
-- so we don't incorrectly unsuppress them later.
create table vger_report.mg_keep_suppressed_201411 as
select
  bm.bib_id
, bm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'mg'
and mm.suppress_in_opac = 'Y'
;
create index vger_report.ix_mg_keep_suppressed_201411 on vger_report.mg_keep_suppressed_201411 (bib_id, mfhd_id);
select count(*) from vger_report.mg_keep_suppressed_201411;
--1558 records

-- Suppress all mfhds in 'mg' location
update mfhd_master 
set suppress_in_opac = 'Y' 
where location_id = (
  select location_id
  from location
  where location_code = 'mg'
)
;

-- Suppress bibs where only holdings are (now-suppressed) 'mg' location.
-- A rough check for single-mfhd bibs is good enough, as the
-- daily bib suppression program will catch the rest.
update bib_master
set suppress_in_opac = 'Y'
where bib_id in (
  select distinct bm.bib_id
  from bib_mfhd bm
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code = 'mg'
  and not exists (
    select *
    from bib_mfhd
    where bib_id = bm.bib_id
    and mfhd_id != mm.mfhd_id
  )
-- 29882
)
;

commit;

/**** Phase 2: Sat Nov 29 2014 ****/

-- Create tmp table first, so we can act on the related bibs and mfhds separately.
create table vger_report.tmp_mg_to_unsuppress as
select
  bm.bib_id
, bm.mfhd_id
from bib_master br
inner join bib_mfhd bm on br.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
where l.location_code = 'mg'
and br.suppress_in_opac = 'Y'
and mm.suppress_in_opac = 'Y'
and not exists (
  select *
  from vger_report.mg_keep_suppressed_201411
  where bib_id = bm.bib_id
  and mfhd_id = bm.mfhd_id
)
and exists (
  select *
  from bib_text
  where bib_id = bm.bib_id
  and (bib_format like '%i' or bib_format like '%m')
)
;
create index vger_report.ix_tmp_mg_to_unsuppress on vger_report.tmp_mg_to_unsuppress (bib_id, mfhd_id);
select count(*) from vger_report.tmp_mg_to_unsuppress;
-- 27720

-- Unsuppress all 'mg' holdings *except* for those which were already suppressed before phase 1
-- and those associated with non-serial bibs (LDR/07 = 'i' or 'm') (filtering done above)
update mfhd_master
set suppress_in_opac = 'N'
where mfhd_id in (select mfhd_id from vger_report.tmp_mg_to_unsuppress)
;
-- 27720


-- Then unsuppress the bibs for those mfhds.
update bib_master
set suppress_in_opac = 'N'
where bib_id in (select bib_id from vger_report.tmp_mg_to_unsuppress)
;
-- 27701

commit;

drop table vger_report.tmp_mg_to_unsuppress purge;
drop table vger_report.mg_keep_suppressed_201411 purge;
