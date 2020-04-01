with clark as (
  select
    bm.bib_id
  , bm.mfhd_id
  , l.location_code
  from bib_mfhd bm
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  where l.location_code like 'ck%'
)
, clark_urls as (
  select distinct
    bs.record_id as bib_id
  , bs.field_seq
  , bs.indicators
  from clark c
  inner join vger_subfields.ucladb_bib_subfield bs on c.bib_id = bs.record_id and bs.tag like '856%'
)
select distinct
  cu.bib_id
, cu.indicators
, vger_subfields.getfieldfromsubfields(cu.bib_id, cu.field_seq) as f856
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.edition) as edition
, vger_support.unifix(bt.imprint) as imprint
, vger_support.unifix(ucladb.GetMarcField(cu.bib_id, 0, 0, '300', '', 'abcefg')) as f300
from clark c
inner join clark_urls cu on c.bib_id = cu.bib_id
inner join bib_text bt on c.bib_id = bt.bib_id
order by cu.bib_id
;


