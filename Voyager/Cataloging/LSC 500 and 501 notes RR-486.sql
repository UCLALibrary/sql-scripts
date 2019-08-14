/*  Various reports for LSC, based on 500 and 501 notes.
    RR-486
*/

-- 1: Reports for records with 500 $5 CLU (exactly)
with bibs as (
  select record_id as bib_id, field_seq
  from vger_subfields.ucladb_bib_subfield
  where tag = '5005'
  and subfield = 'CLU'
)
, yrsp_locs as (
  select location_id, location_code, location_name
  from location
  where location_code in (
    'srar2', 'sryr2', 'yrspald', 'yrspback', 'yrspbcbc', 'yrspbcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbooth', 'yrspboxm'
  , 'yrspboxs', 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 'yrspeip*', 'yrspeip**', 'yrspeip', 'yrspmin', 'yrspo*'
  , 'yrspo**', 'yrspo***', 'yrsprpr', 'yrspstax', 'yrspvault', 'yrspbelt**', 'yrspbelt***', 'yrspinc', 'yrspsafe'
  )
)
select distinct
  b.bib_id
, vger_subfields.getfieldfromsubfields(b.bib_id, b.field_seq) as f500
from bibs b
inner join bib_mfhd bm on b.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join yrsp_locs l on mm.location_id = l.location_id
-- Activate the relevant condition
-- 1) WHERE NOT EXISTS: is not linked to other locations (non-yrsp)
-- 2) WHERE EXISTS: is linked to other locations (non-yrsp)
where not exists ( 
  select * 
  from bib_mfhd bm2
  inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
  where bm2.bib_id = b.bib_id
  and mm2.location_id not in (select location_id from yrsp_locs)
)
order by b.bib_id
;
-- 3012 distinct bibs linked to given locations
-- 2831 have no non-yrsp holdings; 181 do 


-- 2: Reports for records with 501 (any content)
with bibs as (
  select record_id as bib_id, field_seq
  from vger_subfields.ucladb_bib_subfield
  where tag like '501%'
  --and subfield = 'CLU'
)
, yrsp_locs as (
  select location_id, location_code, location_name
  from location
  where location_code in (
    'srar2', 'sryr2', 'yrspald', 'yrspback', 'yrspbcbc', 'yrspbcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbooth', 'yrspboxm'
  , 'yrspboxs', 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 'yrspeip*', 'yrspeip**', 'yrspeip', 'yrspmin', 'yrspo*'
  , 'yrspo**', 'yrspo***', 'yrsprpr', 'yrspstax', 'yrspvault', 'yrspbelt**', 'yrspbelt***', 'yrspinc', 'yrspsafe'
  )
)
select distinct
  b.bib_id
, vger_subfields.getfieldfromsubfields(b.bib_id, b.field_seq) as f501
from bibs b
inner join bib_mfhd bm on b.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join yrsp_locs l on mm.location_id = l.location_id
-- Activate the relevant condition
-- 1) WHERE NOT EXISTS: is not linked to other locations (non-yrsp)
-- 2) WHERE EXISTS: is linked to other locations (non-yrsp)
where exists ( 
  select * 
  from bib_mfhd bm2
  inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
  where bm2.bib_id = b.bib_id
  and mm2.location_id not in (select location_id from yrsp_locs)
)
order by b.bib_id
;
-- 1050 have no non-yrsp holdings; 249 do 