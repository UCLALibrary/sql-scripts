/*  Yet more various queries to support reports for LSC
    RR-537
*/

-- All bib records with <590> field/s, linked to LSC-BIomed locations in the attached list (19 locs)
-- #1 Not linked to any other (non-LSC-Biomed) locs
-- #2 Linked to any other (non-LSC-Biomed) locs

with bibs as (
  select distinct
    record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag like '590%'
)
, lsc as (
  select bm.*
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code in (
    'bihi', 'bihimi', 'bihipam', 'birfhist', 'bisc', 'biscboxm', 'biscboxs', 'bisccg', 'bisccg*', 'bisccg**', 
    'bisccgma', 'biscrbr', 'biscrbr*', 'biscrbrb', 'biscsr', 'biscvlt', 'biscvlt*', 'biscvlt**', 'srbi2'
  )
)
--select count(distinct bib_id) from lsc;
select distinct
  l.bib_id
, vger_support.unifix(substr(ucladb.GetAllBibTag(l.bib_id, '590', 2), 1, 2000)) as f590_all
from lsc l
-- #1: where not exists (
-- #2: where exists (
where not exists (
  select *
  from bib_mfhd
  where bib_id = l.bib_id
  and mfhd_id not in (select mfhd_id from lsc)
)
order by bib_id
;
--16482 (13625,2857)


-- Can I get 2 reports that list all records with a <500>__ that have a “$5 CLU”, “$5 CLUM”, or “$5 CLU-M”, linked to LSC-BIomed locations in the attached list (19 locs) - same as above
-- #3 Not linked to any other (non-LSC-Biomed) locs
-- #4 Linked to any other (non-LSC-Biomed) locs

with bibs as (
  select distinct
    record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '5005'
  and indicators = '  '
  and subfield in ('CLU', 'CLUM', 'CLU-M')
)
, lsc as (
  select bm.*
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code in (
    'bihi', 'bihimi', 'bihipam', 'birfhist', 'bisc', 'biscboxm', 'biscboxs', 'bisccg', 'bisccg*', 'bisccg**', 
    'bisccgma', 'biscrbr', 'biscrbr*', 'biscrbrb', 'biscsr', 'biscvlt', 'biscvlt*', 'biscvlt**', 'srbi2'
  )
)
--select count(distinct bib_id) from lsc;
select distinct
  l.bib_id
, vger_support.unifix(substr(ucladb.GetAllBibTag(l.bib_id, '500', 2), 1, 2000)) as f500_all
from lsc l
-- #3: where not exists (
-- #4: where exists (
where exists (
  select *
  from bib_mfhd
  where bib_id = l.bib_id
  and mfhd_id not in (select mfhd_id from lsc)
)
order by bib_id
;
-- 280 (280, 0)

with bibs as (
  select distinct
    record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '5005'
  and indicators = '  '
  and subfield in ('CLU', 'CLUM', 'CLU-M')
)
select count(*) from bibs;