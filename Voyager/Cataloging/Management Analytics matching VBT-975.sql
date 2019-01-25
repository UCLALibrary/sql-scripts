/*  Match Management Analytics (individual monos) against their parent serials, where possible.
    Supports Management weeding project: VBT-975.
*/

-- All records in mgan location
with mgan as (
  select
    l.location_code
  , ( (select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852h')
    || ' '
    || (select regexp_substr(subfield, '^\S+\s+') from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852i')
  ) as call_no_short
  , mm.display_call_no
  , mm.normalized_call_no
  , bm.bib_id
  , bm.mfhd_id
  from location l
  inner join mfhd_master mm on l.location_id = mm.location_id
  inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
  where l.location_code = 'mgan'
  --and mm.mfhd_id between 1020000 and 1020999
)
-- Serials in mg
, mg as (
  select
    l.location_code
  , mm.display_call_no
  , mm.normalized_call_no
  , bm.bib_id
  , bm.mfhd_id
  from location l
  inner join mfhd_master mm on l.location_id = mm.location_id
  inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
  inner join bib_text bt on bm.bib_id = bt.bib_id
  where l.location_code = 'mg'
  and bt.bib_format = 'as'
)
select
  mgan.bib_id as mgan_bib_id
, mg.bib_id as mg_bib_id
--, mgan.mfhd_id as mgan_mfhd_id
--, mg.mfhd_id as mg_mfhd_id
, mgan.display_call_no as mgan_call_no
, mg.display_call_no as mg_call_no
, ( select replace(normal_heading, 'UCOCLC', '') 
    from bib_index
    where bib_id = mgan.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
) as mgan_oclc
from mgan
left outer join mg on vger_support.NormalizeCallNumber(mgan.call_no_short) = mg.normalized_call_no
-- Change if matches or non-matches are wanted
where mg.bib_id is null
order by mgan.normalized_call_no
;

select * from location where location_code = 'mgan';
--6964 in mgan
-- 969 matches, 5997 matches = 6966 total reported
