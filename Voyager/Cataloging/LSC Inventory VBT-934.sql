/*  Inventory list for selected LSC locations and call number types.
    VBT-934
*/

-- 852 ind1 = '8'
select 
  mm.mfhd_id
, l.location_code
, mm.display_call_no
, vger_subfields.GetSubfields(bm.bib_id, '948a, 948b') as f948ab
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code in 
    ('sryr2', 'srar2', 'yrspalc', 'yrspald', 'yrspcbc', 'yrspcbc*', 'yrspbelt*', 'yrspbelt**', 'yrspboxm', 'yrspboxs'
    , 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 'yrspcoll', 'yrspdh', 'yrspinc', 'yrspmin', 'yrspo*', 'yrspo**'
    , 'yrspo**', 'yrsprpr', 'yrspsafe', 'yrspstax', 'yrspvault'
)
and mm.call_no_type = '8'
order by l.location_code, mm.normalized_call_no
;
-- 19930 rows

-- 852 ind1 = '0', lacking 852 $h or $i (or both)
select 
  mm.mfhd_id
, l.location_code
, mm.display_call_no
, vger_subfields.GetSubfields(bm.bib_id, '948a, 948b') as f948ab
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code in 
    ('sryr2', 'srar2', 'yrspalc', 'yrspald', 'yrspcbc', 'yrspcbc*', 'yrspbelt*', 'yrspbelt**', 'yrspboxm', 'yrspboxs'
    , 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 'yrspcoll', 'yrspdh', 'yrspinc', 'yrspmin', 'yrspo*', 'yrspo**'
    , 'yrspo**', 'yrsprpr', 'yrspsafe', 'yrspstax', 'yrspvault'
)
and mm.call_no_type = '0'
and (   not exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852h')
  or    not exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852i')
)
order by l.location_code, mm.normalized_call_no
;
-- 767 rows
