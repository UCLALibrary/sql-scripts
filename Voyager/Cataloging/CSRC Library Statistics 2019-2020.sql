/*  Various queries to support stats for Chicano Studies (CSRC)
    RR-482 and RR-558
*/

-- CSRC items per SRLF code but not in the SRLF CSR location
select distinct 
  mm.mfhd_id
, l.location_code
, ib.item_barcode
, mi.item_enum
from item_stat_code isc
inner join item_stats ist on isc.item_stat_id = ist.item_stat_id
inner join mfhd_item mi on ist.item_id = mi.item_id
inner join item_barcode ib on ist.item_id = ib.item_id and ib.barcode_status = 1 --Active
inner join mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
where isc.item_stat_code = 'cs1'
and l.location_code != 'srcr'
order by l.location_code, mm.mfhd_id, mi.item_enum
;

-- Bib/mfhd/item counts
with csr as (
  select
    bm.bib_id
  , bm.mfhd_id
  , mi.item_id
  from location l
  inner join mfhd_master mm on l.location_id = mm.location_id
  inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
  left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
  where l.location_code like 'cs%'
)
select 'Bibs' as rec_type, count(distinct bib_id) as records from csr
union all
select 'Hols' as rec_type, count(distinct mfhd_id) as records from csr
union all
select 'Items' as rec_type, count(distinct item_id) as records from csr
;

-- Bibs by bib level
select
  substr(bt.bib_format, 2, 1) as bib_lvl
, count(distinct bt.bib_id) as bibs
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code like 'cs%'
group by substr(bt.bib_format, 2, 1)
order by bib_lvl
;

-- Holdings "in" IML per call number
select
  count(*)
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
where l.location_code like 'cs%'
and mm.display_call_no like '%Held in Instructional Media Library%'
;

-- Holdings by loc
select l.location_code, l.location_name, count(*) as holdings 
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
where l.location_code like 'cs%'
group by l.location_code, l.location_name
order by l.location_code
;

-- UCLA Holdings linked to CSR SPAC
with bibs as (
  select record_id as bib_id
  from vger_subfields.ucladb_bib_subfield bs
  where bs.tag = '901a'
  and bs.subfield = 'CSR'
)
select 
  l.location_code
, l.location_name
, count(distinct b.bib_id) as bibs
from bibs b
inner join bib_mfhd bm on b.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
group by l.location_code, l.location_name
order by l.location_code
;

-- FATA holdings linked to CSC SPAC (different code!)
with bibs as (
  select record_id as bib_id
  from vger_subfields.filmntvdb_bib_subfield bs
  where bs.tag = '901a'
  and bs.subfield = 'CSC'
)
select 
  l.location_code
, l.location_name
, count(distinct b.bib_id) as bibs
from bibs b
inner join filmntvdb.bib_mfhd bm on b.bib_id = bm.bib_id
inner join filmntvdb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join filmntvdb.location l on mm.location_id = l.location_id
group by l.location_code, l.location_name
order by l.location_code



--169620
     
