/*  Inventory list for selected Biomed SC locations and call number types.
    VBT-1665, derived from VBT-934
*/

-- 852 ind1 = '8' (all)
select 
  mm.mfhd_id
, l.location_code
, mm.call_no_type
, mm.display_call_no
, vger_subfields.GetSubfields(bm.bib_id, '948a, 948b') as f948ab
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code in 
  ( 'bihi', 'bihimi', 'bihipam', 'birfhist', 'bisc', 'biscboxm', 'biscboxs', 'bisccg', 'bisccg*', 'bisccg**'
  , 'bisccgma', 'biscrbr', 'biscrbr*', 'biscrbrb', 'biscsr', 'biscvlt', 'biscvlt*', 'biscvlt**', 'srbi2'
)
and mm.call_no_type = '8'
order by mm.call_no_type, l.location_code, mm.normalized_call_no
;
-- 11006 rows

-- 852 ind1 = '0' or '2', lacking 852 $h or $i (or both)
select 
  mm.mfhd_id
, l.location_code
, mm.call_no_type
, mm.display_call_no
, vger_subfields.GetSubfields(bm.bib_id, '948a, 948b') as f948ab
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code in 
  ( 'bihi', 'bihimi', 'bihipam', 'birfhist', 'bisc', 'biscboxm', 'biscboxs', 'bisccg', 'bisccg*', 'bisccg**'
  , 'bisccgma', 'biscrbr', 'biscrbr*', 'biscrbrb', 'biscsr', 'biscvlt', 'biscvlt*', 'biscvlt**', 'srbi2'
)
and mm.call_no_type in ('0', '2')
and (   not exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852h')
  or    not exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852i')
)
order by mm.call_no_type, l.location_code, mm.normalized_call_no
;
-- 295 rows
