/*  List of PDACQ records containing numbered series statements
    RR-327
*/
-- Main query
with bibs as (
  select record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '852b'
  and subfield = 'pdacq'
)
select 
  b.bib_id
, vger_support.unifix(bt.title_brief) as title_brief
, vger_subfields.GetFieldFromSubfields(bs.record_id, bs.field_seq) as f490
from bibs b
inner join bib_text bt on b.bib_id = bt.bib_id
inner join vger_subfields.ucladb_bib_subfield bs on b.bib_id = bs.record_id and bs.tag = '490v'
order by b.bib_id
;
-- 4042 bibs with 4067 total rows as of 2018-02-22

-- Exploration

-- Bibs with 852 $b pdacq, due to loading process
select subfield, count(*) as num
from vger_subfields.ucladb_bib_subfield
where tag = '852b'
group by subfield
order by subfield
;
-- 50022

-- Holdings with 852 $b pdacq - current location
select * from location where location_code = 'pdacq';
-- 45814

-- pdacq bibs without pdacq holdings, generally due to being requested and/or received otherwise
with bibs as (
  select record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '852b'
  and subfield = 'pdacq'
)
select count(distinct b.bib_id)
from bibs b
left outer join bib_mfhd bm on b.bib_id = bm.bib_id
where not exists (
  select * from mfhd_master
  where mfhd_id = bm.mfhd_id
  and location_id = 689 --pdacq
)
;
-- 4245

-- pdacq holdings without pdacq bibs, due to either (a) loaded today after subfield db update, or (b) unknown, but very few of those
with bibs as (
  select record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '852b'
  and subfield = 'pdacq'
)
select *
from mfhd_master mm
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where location_id = 689 --pdacq
and not exists (
  select *
  from bibs
  where bib_id = bm.bib_id
)
;
-- 22