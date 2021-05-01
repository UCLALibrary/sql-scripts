/*  LSC holdings records with no items.
    VBT-1776
*/

select
  bm.bib_id
, bm.mfhd_id
, vger_support.get_oclc_number(bm.bib_id) as oclc
, substr(bt.bib_format, 2, 1) as bib_lvl
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = bt.bib_id and tag = '300a' and rownum < 2) as f300a
, l.location_code
, (select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852x' and rownum < 2) as f852x
, (select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852z' and rownum < 2) as f852z
, (select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '866a' and rownum < 2) as f866a
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code in (
  'yrspstax', 'yrspald', 'yrspback', 'yrspbcbc', 'yrspbcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbelt**', 'yrspbooth', 'yrspboxm'
, 'yrspboxs', 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 'yrspinc', 'yrspmin', 'yrspo*', 'yrspo**', 'yrspo***', 'yrsprpr'
, 'yrspvault', 'yrspsafe', 'biscboxm', 'biscboxs'
)
and not exists (select * from mfhd_item where mfhd_id = mm.mfhd_id)
order by bm.bib_id, bm.mfhd_id
;
--173799 rows