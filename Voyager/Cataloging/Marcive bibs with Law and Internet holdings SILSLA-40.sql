/*  Marcive bibs with Internet and Law holdings.
    SILSLA-40.
*/

with bibs as (
  select bs.record_id as bib_id
  from vger_subfields.ucladb_bib_subfield bs
  where tag = '910a'
  and subfield like '%marcive%'
)
, law as (
  select distinct
    b.bib_id
  , bm.mfhd_id
  , l.location_code
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code like 'lw%'
) 
, internet as (
  select distinct
    b.bib_id
  , bm.mfhd_id
  , l.location_code
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code = 'in'
)
select distinct
  l.bib_id
, (select listagg(law.location_code, ', ') within group (order by law.location_code) from law where bib_id = l.bib_id) as locs
, substr(bt.bib_format, 2, 1) as bib_lvl
from law l
inner join bib_text bt on l.bib_id = bt.bib_id
-- Reported also on "not exists"
where exists (select * from internet where bib_id = l.bib_id)
order by l.bib_id
;
 