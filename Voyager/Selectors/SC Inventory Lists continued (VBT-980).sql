/*  PASC/LSC inventories
    Modified from https://github.com/UCLALibrary/sql-scripts/blob/master/Voyager/Selectors/SC%20Inventory%20Lists.sql
    VBT-980
*/

-- Report 1
select
  bt.bib_id
, bt.language
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title_brief -- 245 $a $b
, ( select subfield 
    from vger_subfields.ucladb_bib_subfield
    where record_id = bt.bib_id
    and tag = '245c'
    and rownum < 2
  ) as f245c
, bt.pub_dates_combined
, mm.mfhd_id
, l.location_code
, mm.display_call_no
-- Need all mfhd 852 subfield $x and $z, not just first
, vger_subfields.GetSubfields(mm.mfhd_id, '852x', 'mfhd', 'ucladb') as f852x
, vger_subfields.GetSubfields(mm.mfhd_id, '852z', 'mfhd', 'ucladb') as f852z
, ucladb.GetAllMfhdTag(mm.mfhd_id, '901') as f901
, ucladb.GetAllMfhdTag(mm.mfhd_id, '917') as f917
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code in ('yrspback', 'yrspbcbc', 'yrspbcbc*', 'yrspeip', 'yrspeip*', 'yrspeip**')
order by l.location_code, mm.normalized_call_no
;
-- 15033 rows

-- Report 2, with 910 filters + 050 & 090
select
  bt.bib_id
, bt.language
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title_brief -- 245 $a $b
, ( select subfield 
    from vger_subfields.ucladb_bib_subfield
    where record_id = bt.bib_id
    and tag = '245c'
    and rownum < 2
  ) as f245c
, bt.pub_dates_combined
, mm.mfhd_id
, l.location_code
, mm.display_call_no
-- Need all mfhd 852 subfield $x and $z, not just first
, vger_subfields.GetSubfields(mm.mfhd_id, '852x', 'mfhd', 'ucladb') as f852x
, vger_subfields.GetSubfields(mm.mfhd_id, '852z', 'mfhd', 'ucladb') as f852z
, ucladb.GetAllMfhdTag(mm.mfhd_id, '901') as f901
, ucladb.GetAllMfhdTag(mm.mfhd_id, '917') as f917
, ucladb.GetAllBibTag(bt.bib_id, '050') as f050
, ucladb.GetAllBibTag(bt.bib_id, '090') as f090
, bs.subfield as f910a
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
-- must have selected 910 $a
inner join vger_subfields.ucladb_bib_subfield bs on bt.bib_id = bs.record_id and bs.tag = '910a'
where l.location_code in ('yrspback', 'yrspbcbc', 'yrspbcbc*', 'yrspeip', 'yrspeip*', 'yrspeip**')
and bs.subfield in ('oclcmellon1', 'oclcmellon2match', 'oclcmellon2nomatch')
order by l.location_code, mm.normalized_call_no
;
-- 11861 rows

