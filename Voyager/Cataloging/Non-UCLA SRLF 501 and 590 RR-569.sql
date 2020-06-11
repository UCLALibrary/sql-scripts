/*  1) Non-UCLA bibs with 590 fields for items deposited at SRLF
    2) Non-UCLA bibs with 501 fields (also at SRLF)
    RR-569
*/

-- 1) Non-UCLA bibs with 590 fields for items deposited at SRLF
with bibs as (
  select distinct
    record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag like '590%'
)
, items as (
  select distinct -- needed for clean LISTAGG later
    b.bib_id
  , isc.item_stat_code_desc
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  inner join mfhd_item mi on bm.mfhd_id = mi.mfhd_id
  inner join item_stats ist on mi.item_id = ist.item_id
  inner join item_stat_code isc on ist.item_stat_id = isc.item_stat_id
  where l.location_code like 'sr%'
  and regexp_like(item_stat_code, '^u[bcdikmrsv][0-9]$')
)
select 
  i.bib_id
, listagg(i.item_stat_code_desc, ', ') within group (order by i.item_stat_code_desc) as depositors
, vger_support.unifix(substr(ucladb.GetAllBibTag(i.bib_id, '590', 1), 1, 2000)) as f590_all -- plain format
from items i
group by i.bib_id
order by i.bib_id
;
-- 26625 bibs

-- 2) Non-UCLA bibs with 501 fields (also at SRLF)
with bibs as (
  select distinct
    record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag like '501%'
)
, items as (
  select distinct -- needed for clean LISTAGG later
    b.bib_id
  , isc.item_stat_code_desc
  from bibs b
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  inner join mfhd_item mi on bm.mfhd_id = mi.mfhd_id
  inner join item_stats ist on mi.item_id = ist.item_id
  inner join item_stat_code isc on ist.item_stat_id = isc.item_stat_id
  where l.location_code like 'sr%'
  and regexp_like(item_stat_code, '^u[bcdikmrsv][0-9]$')
)
select 
  i.bib_id
, listagg(i.item_stat_code_desc, ', ') within group (order by i.item_stat_code_desc) as depositors
, vger_support.unifix(substr(ucladb.GetAllBibTag(i.bib_id, '501', 1), 1, 50)) as f501_all -- plain format, wants just first 50 char for these
from items i
group by i.bib_id
order by i.bib_id
;
-- 635 bibs