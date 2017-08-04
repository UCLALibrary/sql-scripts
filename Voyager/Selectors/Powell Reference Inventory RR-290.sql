/*  List of Powell Reference titles, with subjects
    and flag if held in other locations.
    RR-290
*/

select 
  l.location_code
, l.location_name
, mm.display_call_no
, case
    when exists (
      select * 
      from bib_mfhd bm2 
      inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
      inner join location l2 on mm2.location_id = l2.location_id
      where bm2.bib_id = bt.bib_id
      and l2.location_code not like 'cl%'
      and mm2.suppress_in_opac = 'N'
    )
    then 'Y'
    else null
  end as non_college
, bt.bib_id
, vger_support.unifix(bt.title_brief) as title_brief
, bt.pub_dates_combined as pub_dates
, vger_support.get_subjects(bt.bib_id) as subjects_650_651
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code like 'clrf%'
order by l.location_code, mm.normalized_call_no
;

