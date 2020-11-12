/*  Bibs with multiple 035 $a (OCoLC), all different after normalization
    SILSLA-36
*/

with bibs as (
  select distinct
    record_id
  , regexp_replace(regexp_replace(subfield, '[A-Z,a-z, \(\)]', ''), '^0+', '') as oclc
  from vger_subfields.ucladb_bib_subfield
  where tag = '035a'
  and subfield like '(OCoLC)%'
  --and record_id <= 1000000 -- = 3809062
)
, dups as (
  select record_id as bib_id
  from bibs
  group by record_id
  having count(*) > 1
) --select count(distinct bib_id) from dups;
select distinct
  d.bib_id
, l.location_code
, substr(bt.bib_format, 2, 1) as bib_lvl
from dups d
inner join bib_mfhd bm on d.bib_id = bm.bib_id
inner join bib_text bt on d.bib_id = bt.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
order by d.bib_id, l.location_code
;
-- 991 rows, 814 bibs0201112