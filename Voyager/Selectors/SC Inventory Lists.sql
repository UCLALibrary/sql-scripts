/*  PASC/LSC inventories
    Same SQL, different locations and other minor tweaks, per:
    https://jira.library.ucla.edu/browse/VBT-760
    https://jira.library.ucla.edu/browse/VBT-761
    https://jira.library.ucla.edu/browse/VBT-762
    See inline comments for issue-specific tweaks
*/

select
  bt.bib_id
, bt.language -- only VBT-762 needs language included
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title_brief -- 245 $a $b
, ( select subfield 
    from vger_subfields.ucladb_bib_subfield
    where record_id = bt.bib_id
    and tag = '245c'
    and rownum < 2
  ) as f245c
, vger_support.unifix(bt.imprint) as imprint
, mm.mfhd_id
, l.location_code
, mm.display_call_no
-- Need all mfhd 852 subfield $x and $z, not just first
, vger_subfields.GetSubfields(mm.mfhd_id, '852x', 'mfhd', 'ucladb') as f852x
, vger_subfields.GetSubfields(mm.mfhd_id, '852z', 'mfhd', 'ucladb') as f852z
-- only VBT-762 needs holdings 901 and 917 fields included
, ucladb.GetAllMfhdTag(mm.mfhd_id, '901') as f901
, ucladb.GetAllMfhdTag(mm.mfhd_id, '917') as f917
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
/*
where l.location_code in ('arsc', 'arscrr', 'musc', 'musc*', 'musc**', 'musc***', 'muscarch', 'muscfacs', 'muscmanu', 'muscmini',
'muscobl', 'muscoblfac', 'muscrf', 'muscsdr', 'muscsheet', 'muscspc', 'muscstax', 'musctoc', 'musctoc*'
) -- VBT-760
where l.location_code = 'muscfolio' -- VBT-761
*/
where l.location_code = 'yrspback' -- VBT-762
order by l.location_code, mm.normalized_call_no
;
