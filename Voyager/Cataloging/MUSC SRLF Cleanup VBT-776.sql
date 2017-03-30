with music as (
  select
    l.location_code
  , bm.bib_id
  , bm.mfhd_id
  from location l
  inner join mfhd_master mm on l.location_id = mm.location_id
  inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
  where l.location_code in ('musc', 'musc*', 'musc**', 'musc***', 'muscfacs', 'muscmanu', 'muscmini', 'muscobl', 'muscoblfac', 'muscrf', 'muscsheet', 'musctoc', 'musctoc*')
)
--select count(*), count(distinct mfhd_id), count(distinct location_code) from music --5117 bib/mfhd pairs, 4890 mfhds, 12 locs - nothing in musc***
, srar2 as (
  select
    l.location_code
  , bm.bib_id
  , bm.mfhd_id
  from location l
  inner join mfhd_master mm on l.location_id = mm.location_id
  inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
  where l.location_code = 'srar2'
)
select 
  distinct m.mfhd_id, location_code
from music m
where exists (
  select * from srar2 where bib_id = m.bib_id
)
order by mfhd_id
-- 2555 mfhds, 2565 bib/mfhd pairs
;
