/*  Selection of MARC data for materials in YRL map collections.
    RR-403
*/

select
  ( select replace(normal_heading, 'UCOCLC') from bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
) as oclc
, bt.bib_id
, 'https://catalog.library.ucla.edu/vwebv/holdingsInfo?bibId=' || bt.bib_id as permalink
, l.location_code
, mm.normalized_call_no
, mm.display_call_no
, ( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from bib_location bl
    inner join location l2 on bl.location_id = l2.location_id
    where bl.bib_id = bt.bib_id
    and l2.location_code != l.location_code
) as other_locs
, substr(bt.bib_format, 2, 1) as bib_lvl
, substr(bt.bib_format, 1, 1) as record_type
, substr(bt.field_008, 29, 1) as govt_pub -- 008/28
, bt.place_code
, bt.language
, bt.date_type_status as dt_status
, bt.begin_pub_date as date1
, bt.end_pub_date as date2
, ( select subfield from vger_subfields.ucladb_bib_subfield where record_id = bt.bib_id and tag = '043a' and subfield_seq = 1) as gac1
, ( select subfield from vger_subfields.ucladb_bib_subfield where record_id = bt.bib_id and tag = '043a' and subfield_seq = 2) as gac2
, ( select subfield from vger_subfields.ucladb_bib_subfield where record_id = bt.bib_id and tag = '043a' and subfield_seq = 3) as gac3
, vger_subfields.GetSubfields(bt.bib_id, '052a,052b') as f052ab
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_subfields.GetFirstSubfield(bt.bib_id, '034b') as scale_code
, coalesce(vger_subfields.GetFirstSubfield(bt.bib_id, '255a'), vger_subfields.GetFirstSubfield(bt.bib_id, '507a')) as scale_text
, vger_support.unifix(ucladb.GetBibTag(bt.bib_id, '260 264')) as pub_info
, vger_subfields.GetFirstSubfield(bt.bib_id, '300a') as physical_extent
, vger_subfields.GetSubfields(bt.bib_id, '776i,776a,776t,776w') as other_form
, ucladb.GetAllBibTag(bt.bib_id, '856', 2) as urls
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code in ('yrmapc', 'yrmaphmpc', 'yrmaphvfc', 'yrmapstx', 'yrmapvf', 'yrrismaps')
order by l.location_code, mm.normalized_call_no
;
-- 28725 rows 2018-11-13
