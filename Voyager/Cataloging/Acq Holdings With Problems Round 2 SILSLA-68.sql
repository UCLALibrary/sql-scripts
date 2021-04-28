/*  Revised report on "acq" holdings.
    Modified from 2nd (modified) query on SILSLA-26.
    SILSLA-68
*/

select 
  bm.bib_id
, substr(bt.bib_format, 2, 1) as bib_lvl
, replace(substr(bt.field_008, 24, 1), ' ', '#') as item_frm --008/23, not valid for maps and visual materials (both 008/29)
, bm.mfhd_id
, l.location_code
, mm.suppress_in_opac as mfhd_suppr
, case
    when exists (select * from line_item_copy_status where mfhd_id = mm.mfhd_id)
    then 'Y'
    else 'N'
end as has_po
, vger_subfields.getfieldfromsubfields(ms.record_id, ms.field_seq, 'mfhd') as f852
from mfhd_master mm
inner join location l on mm.location_id = l.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join vger_subfields.ucladb_mfhd_subfield ms on mm.mfhd_id = ms.record_id and ms.tag = '852b'
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code like '%acq%'
and l.location_code != 'pdacq'
and mm.create_date < to_date('20190101', 'YYYYMMDD')
order by location_code, bib_id, mfhd_id
;
--5547 rows 2021-04-27
