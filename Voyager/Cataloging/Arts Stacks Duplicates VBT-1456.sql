select
  bm.bib_id
, bm.mfhd_id
, l.location_code
, mm.suppress_in_opac as mfhd_suppressed
, mm.display_call_no
, ( select listagg(l3.location_code, ', ') within group (order by l3.location_code)
    from bib_location bl2
    inner join location l3 on bl2.location_id = l3.location_id
    where bl2.bib_id = bm.bib_id
    and l3.location_code like 'ar%'
) as arts_locs
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code in ('ar', 'ar*', 'ar**&***')
and not exists (
  select *
  from mfhd_item
  where mfhd_id = mm.mfhd_id
)
and exists (
  select *
  from bib_mfhd bm2
  inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
  inner join location l2 on mm2.location_id = l2.location_id
  where bm2.bib_id = bm.bib_id
  and bm2.mfhd_id != mm.mfhd_id
  and l2.location_code like 'ar%'
  and l2.location_code != 'arsr'
)
order by l.location_code, bm.bib_id, bm.mfhd_id
;
-- 108923 Arts records (all locs) with no items
-- Removing arsr gets down to 30172
-- 1922 have other Arts holdings

select * from location where location_code like 'ar%' order by location_code;