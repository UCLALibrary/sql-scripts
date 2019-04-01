/*  Various queries to support reports/updates for LSC
    RR-420
*/

-- Bibs which have sryr2 holdings with various criteria
select distinct
  bm.bib_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code = 'sryr2'
-- No yrsp holdings attached to this bib
and not exists (
  select * 
  from location l2
  inner join mfhd_master mm2 on l2.location_id = mm2.location_id
  inner join bib_mfhd bm2 on mm2.mfhd_id = bm2.mfhd_id
  where bm2.bib_id = bm.bib_id
  and l2.location_code like 'yrsp%'
)
-- No 590 already in the bib record
and not exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bm.bib_id
  and tag like '590%'
)
/*  Uncomment each of the 3 holdings filters below, separately, to generate 3 lists */
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852z' and lower(subfield) = 'on deposit')
-- 7961 qualify
--and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '916a' and subfield = 'Pre-1850 material from YRL stacks (2012)')
-- 1694 qualify
--and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'BEL')
-- 4887 qualify
order by bm.bib_id
;

--select * from bib_history where action_date > trunc(sysdate) and operator_id = 'lisprogram' order by action_date desc;

-- Bibs which have yrspbelt holdings with various criteria
select distinct
  bm.bib_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code = 'yrspbelt'
-- No (other) yrsp holdings attached to this bib
and not exists (
  select * 
  from location l2
  inner join mfhd_master mm2 on l2.location_id = mm2.location_id
  inner join bib_mfhd bm2 on mm2.mfhd_id = bm2.mfhd_id
  where bm2.bib_id = bm.bib_id
  and mm2.mfhd_id != mm.mfhd_id
  and l2.location_code like 'yrsp%'
)
-- No 590 already in the bib record
and not exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bm.bib_id
  and tag like '590%'
)
order by bm.bib_id
;
-- 523 bib records

-- 
-- Bibs which have sryr2 holdings with various criteria which are skipped above because they *do* have yrsp holdings and 590 fields already
select distinct
  bm.bib_id
, mm.display_call_no
, vger_subfields.GetSubfields(mm.mfhd_id, '852z', 'mfhd', 'ucladb') as f852z_all
, ucladb.GetAllMFHDTag(mm.mfhd_id, '916', 2) as f916_all
, ucladb.GetAllMFHDTag(mm.mfhd_id, '901', 2) as f901_all
--, ucladb.getmfhdtag(mm.mfhd_id, '916') as foo
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code = 'sryr2'
-- YES yrsp holdings attached to this bib
and exists (
  select * 
  from location l2
  inner join mfhd_master mm2 on l2.location_id = mm2.location_id
  inner join bib_mfhd bm2 on mm2.mfhd_id = bm2.mfhd_id
  where bm2.bib_id = bm.bib_id
  and l2.location_code like 'yrsp%'
)
-- YES 590 already in the bib record
and exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bm.bib_id
  and tag like '590%'
)
/*  Uncomment each of the 3 holdings filters below, separately, to generate 3 lists */
--and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852z' and lower(subfield) = 'on deposit')
-- 254 qualify
--and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '916a' and subfield = 'Pre-1850 material from YRL stacks (2012)')
-- 110 qualify
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'BEL')
-- 253 qualify
order by bm.bib_id
;

-- Bibs which have 590 $a starting with other than: "Spec. Coll.", and have sryr2 and/or yrsp% holdings
select distinct
  bm.bib_id
, ucladb.GetAllBibTag(bm.bib_id, '590', 2) as f590_all
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where ( l.location_code = 'sryr2' or l.location_code like 'yrsp%')
and exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bm.bib_id
  and tag = '590a'
  -- Requested 'Spec. Coll.%' but filter out those without terminal period as they're probably errors, like bib 8843361
  and subfield not like 'Spec. Coll%'
)
-- Does, or does not, have other holdings: adjust EXISTS / NOT EXISTS as needed
and  exists (
  select * 
  from location l2
  inner join mfhd_master mm2 on l2.location_id = mm2.location_id
  inner join bib_mfhd bm2 on mm2.mfhd_id = bm2.mfhd_id
  where bm2.bib_id = bm.bib_id
  and mm2.mfhd_id != mm.mfhd_id
  and l2.location_code != 'sryr2' 
  and l2.location_code not like 'yrsp%'
)
-- No other holdings: 
order by bm.bib_id
;
-- 29042 with no other holdings
-- 9749 with other holdings
