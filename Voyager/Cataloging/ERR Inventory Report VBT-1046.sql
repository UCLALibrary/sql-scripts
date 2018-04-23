/*  ERR inventory report.
    VBT-1046
*/

select 
  l.location_code
, l.location_name
, mm.display_call_no
, vger_support.unifix(bt.author) as author
, vger_support.unifix(title_brief) as title_brief
, vger_support.unifix(edition) as edition
, vger_support.unifix(imprint) as imprint
, (select count(*) from mfhd_item where mfhd_id = mm.mfhd_id) as items
, ( select subfield from vger_subfields.ucladb_mfhd_subfield
    where record_id = mm.mfhd_id
    and tag = '866a'
    and rownum < 2
) as f866a
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code like 'er%'
and l.location_code != 'ersr' -- exclude SRLF "ghost" records
order by l.location_code, mm.normalized_call_no
;

