/*  yrofcat holdings updated by a human in the last 2 years.
    RR-639
*/

select
  mm.mfhd_id
, ( select max(action_date) from mfhd_history 
    where mfhd_id = mm.mfhd_id
    and operator_id not in ('load', 'lisprogram', 'scploader', 'marsloader', 'uclaloader', 'nomelvyl', 'GLOBAL', 'promptcat')
) as last_update
, vger_support.unifix(bt.title) as title
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrofcat'
and exists (
  select * from mfhd_history
  where mfhd_id = mm.mfhd_id
  and action_date >= (sysdate - 730)
  and operator_id not in ('load', 'lisprogram', 'scploader', 'marsloader', 'uclaloader', 'nomelvyl', 'GLOBAL', 'promptcat')
)
order by mm.mfhd_id
;

