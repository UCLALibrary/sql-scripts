/*  Inventory of ckpress location.
    RR-271
*/

select --count(distinct bm.bib_id) as bibs, count(distinct bm.mfhd_id) as hols
  bt.bib_id
, mm.mfhd_id
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.imprint) as imprint -- includes 260 or 264
, GetBibTag(bt.bib_id, '300') as fld_300
, GetMFHDTag(mm.mfhd_id, '852') as fld_852
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
--left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
where l.location_code = 'ckpress'
order by mm.normalized_call_no, bt.bib_id
;
-- 11002 bibs, 11465 mfhds; only 289 items when IJ mfhd_item; 11626 rows when LOJ mfhd_item
