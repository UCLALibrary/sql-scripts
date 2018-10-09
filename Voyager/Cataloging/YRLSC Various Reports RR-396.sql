/*  Various YRLSC reports
    RR-396
*/

-- Report 1: multiple YRLSC holdings records on the same bib record
with yrlsc as (
  select 
    bm.*
  , mm.normalized_call_no
  , mm.display_call_no
  , l.location_code
  from bib_mfhd bm
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code in ('srar2', 'sryr2')
  or l.location_code in (
    	'yrscacq', 'yrspalc', 'yrspald', 'yrspback', 'yrspbcbc', 'yrspbcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbelt**', 'yrspbooth', 'yrspboxm'
    ,	'yrspboxs', 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 'yrspcoll', 'yrspdh', 'yrspeip', 'yrspeip*', 'yrspeip**', 'yrspinc', 'yrspmin'
    ,	'yrspo*', 'yrspo**', 'yrspo***', 'yrsprpr', 'yrspsafe', 'yrspstax', 'yrspvault'
  )
)
-- 304306
select 
  y1.bib_id
, substr(bt.bib_format, 2, 1) as bib_lvl
, ( select subfield from vger_subfields.ucladb_bib_subfield where tag = '300a' and record_id = y1.bib_id and rownum < 2) as f300a
, y1.mfhd_id as mfhd_id_1
, y1.location_code as loc_1
, y1.display_call_no as call_no_1
, ( select subfield from vger_subfields.ucladb_mfhd_subfield where tag = '852z' and record_id = y1.mfhd_id and rownum < 2) as f852z_1
, ( select substr(subfield, 1, 30) from vger_subfields.ucladb_mfhd_subfield where tag = '866a' and record_id = y1.mfhd_id and rownum < 2) as f866a_1
, ( select count(*) from mfhd_item where mfhd_id = y1.mfhd_id) as items_1
-----
, y2.mfhd_id as mfhd_id_2
, y2.location_code as loc_2
, y2.display_call_no as call_no_2
, ( select subfield from vger_subfields.ucladb_mfhd_subfield where tag = '852z' and record_id = y2.mfhd_id and rownum < 2) as f852z_2
, ( select substr(subfield, 1, 30) from vger_subfields.ucladb_mfhd_subfield where tag = '866a' and record_id = y2.mfhd_id and rownum < 2) as f866a_2
, ( select count(*) from mfhd_item where mfhd_id = y2.mfhd_id) as items_2
from yrlsc y1
inner join yrlsc y2 on y1.bib_id = y2.bib_id
inner join bib_text bt on y1.bib_id = bt.bib_id
where y1.mfhd_id < y2.mfhd_id
order by y1.bib_id, y1.mfhd_id, y2.mfhd_id
;
-- example of bib with 3 holdings: 1617; 3 rows, 1 for each unique pair of holdings

-- Report 2: Potential bound-withs
-- 2 or more holdings with matching call $h and $i (don't worry about $k) for all YRLSC holdings (excluding yrspboxs, yrspboxm, and yrspsr), sryr2 and srar2
-- Variant: match just on call number, ignoring bib id.
with yrlsc as (
  select 
    bm.*
  , mm.normalized_call_no
  , mm.display_call_no
  , l.location_code
  from bib_mfhd bm
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code in ('srar2', 'sryr2')
  or l.location_code in (
    	'yrscacq', 'yrspalc', 'yrspald', 'yrspback', 'yrspbcbc', 'yrspbcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbelt**', 'yrspbooth' -- 'yrspboxm', 'yrspboxs'
    , 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 'yrspcoll', 'yrspdh', 'yrspeip', 'yrspeip*', 'yrspeip**', 'yrspinc', 'yrspmin'
    ,	'yrspo*', 'yrspo**', 'yrspo***', 'yrsprpr', 'yrspsafe', 'yrspstax', 'yrspvault'
  )
)
-- 225081
select 
  y1.bib_id
, substr(bt.bib_format, 2, 1) as bib_lvl
, ( select subfield from vger_subfields.ucladb_bib_subfield where tag = '300a' and record_id = y1.bib_id and rownum < 2) as f300a
, y1.mfhd_id as mfhd_id_1
, y1.location_code as loc_1
, y1.display_call_no as call_no_1
, ( select subfield from vger_subfields.ucladb_mfhd_subfield where tag = '852z' and record_id = y1.mfhd_id and rownum < 2) as f852z_1
-----
, y2.mfhd_id as mfhd_id_2
, y2.location_code as loc_2
, y2.display_call_no as call_no_2
, ( select subfield from vger_subfields.ucladb_mfhd_subfield where tag = '852z' and record_id = y2.mfhd_id and rownum < 2) as f852z_2
from yrlsc y1
inner join yrlsc y2 on y1.bib_id = y2.bib_id
inner join bib_text bt on y1.bib_id = bt.bib_id
where y1.mfhd_id < y2.mfhd_id
and y1.display_call_no = y2.display_call_no
order by y1.bib_id, y1.mfhd_id, y2.mfhd_id
;

-- Report 2 variant: match call no regardless of bib id
with yrlsc as (
  select 
    bm.*
  , mm.normalized_call_no
  , mm.display_call_no
  , mm.call_no_type
  , l.location_code
  from bib_mfhd bm
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code in ('srar2', 'sryr2')
  or l.location_code in (
    	'yrscacq', 'yrspalc', 'yrspald', 'yrspback', 'yrspbcbc', 'yrspbcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbelt**', 'yrspbooth' -- 'yrspboxm', 'yrspboxs'
    , 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 'yrspcoll', 'yrspdh', 'yrspeip', 'yrspeip*', 'yrspeip**', 'yrspinc', 'yrspmin'
    ,	'yrspo*', 'yrspo**', 'yrspo***', 'yrsprpr', 'yrspsafe', 'yrspstax', 'yrspvault'
  )
)
-- 225081
select 
  y1.bib_id as bib_id_1
, ( select substr(bib_format, 2, 1) from bib_text where bib_id = y1.bib_id) as bib_lvl_1
, ( select subfield from vger_subfields.ucladb_bib_subfield where tag = '300a' and record_id = y1.bib_id and rownum < 2) as f300a_1
, y1.mfhd_id as mfhd_id_1
, y1.location_code as loc_1
, y1.display_call_no as call_no_1
, ( select subfield from vger_subfields.ucladb_mfhd_subfield where tag = '852z' and record_id = y1.mfhd_id and rownum < 2) as f852z_1
-----
, y2.bib_id as bib_id_2
, ( select substr(bib_format, 2, 1) from bib_text where bib_id = y2.bib_id) as bib_lvl_2
, ( select subfield from vger_subfields.ucladb_bib_subfield where tag = '300a' and record_id = y2.bib_id and rownum < 2) as f300a_2
, y2.mfhd_id as mfhd_id_2
, y2.location_code as loc_2
, y2.display_call_no as call_no_2
, ( select subfield from vger_subfields.ucladb_mfhd_subfield where tag = '852z' and record_id = y2.mfhd_id and rownum < 2) as f852z_2
from yrlsc y1
inner join yrlsc y2 on y1.display_call_no = y2.display_call_no
where y1.mfhd_id < y2.mfhd_id
and y1.call_no_type = '0'
and y1.bib_id = y2.bib_id
order by y1.normalized_call_no, y1.bib_id, y1.mfhd_id, y2.mfhd_id
;
-- Example of diff bibs: 6071/21918

-- Reports 3-4: Re-ran reports from VBT-934

-- Report 5: Re-ran report from RR-304, adding bib 540 field
