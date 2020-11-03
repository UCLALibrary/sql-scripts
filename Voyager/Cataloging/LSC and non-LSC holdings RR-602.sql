/*  Bibs with LSC and non-LSC holdings.
    RR-602
*/

with locs as (
  select *
  from location
  where location_code in (
    'arsc', 'bihi', 'bihibjnl', 'bihimi', 'bihipam', 'birfhist', 'bisc', 'biscboxm', 'biscboxs', 
    'bisccg', 'bisccg*', 'bisccg**', 'bisccgma', 'biscrbr', 'biscrbr*', 'biscrbrb', 'biscvlt', 'biscvlt*', 
    'biscvlt**', 'musc', 'musc**', 'muscsheet', 'scscmorgan', 'srar2', 'srbi2', 'sryr2', 'sryr7', 'uaref', 
    'yrscacq', 'yrspald', 'yrspback', 'yrspbcbc', 'yrspbcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbelt**', 'yrspbooth', 
    'yrspboxm', 'yrspboxs', 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 'yrspcoll', 'yrspdh', 'yrspinc', 'yrspmin', 
    'yrspo*', 'yrspo**', 'yrspo***', 'yrsprpr', 'yrspsafe', 'yrspstax', 'yrspvault'
    --, 'arscsr', 'biscsr', 'uasr', 'yrspsr'
  )
)
, lsc as (
  select
    bm.*
  , l.location_id
  , l.location_code
  from locs l
  inner join mfhd_master mm on l.location_id = mm.location_id
  inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
  where l.location_id in (select location_id from locs)
)
--select count(*) from lsc -- 437613
select count(distinct bib_id)
from lsc s
where exists (
  select *
  from bib_mfhd bm
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  where bib_id = s.bib_id
  and mm.location_id not in (select location_id from locs)
)
;
-- 154653 without yrspsr; 104989 with

