/*  Reports on duplicate URLs (856 $u) within individual bib records.
    VBT-1775
*/

-- Report 1: openurl dup 856 $u, UCLA only
with d as (
  select
    bs.record_id as bib_id
  , bs.field_seq
  , bs.tag
  , bs.indicators
  , bs.subfield as f856u
  , ( select subfield from vger_subfields.ucladb_bib_subfield
      where record_id = bs.record_id
      and field_seq = bs.field_seq
      and tag = '856x'
      and rownum < 2
  ) as f856x
  from vger_subfields.ucladb_bib_subfield bs
  where tag = '856u'
  and indicators in ('40', '41')
  and subfield like '%openurl.cdlib.org%'
)
select
  d.bib_id
, substr(bt.bib_format, 2, 1) as bib_lvl
, vger_support.unifix(bt.title_brief) as title
, count(*) as fields
, d.f856u
, d.f856x
from d
inner join bib_text bt on d.bib_id = bt.bib_id
where d.f856x like '%UCLA%'
group by d.bib_id, bt.bib_format, bt.title_brief, d.f856u, d.f856x
having count(*) > 1
order by d.bib_id
;
-- 161 field sets

-- Report 2: non-openurl dup 856 $u, all
with d as (
  select
    bs.record_id as bib_id
  , bs.field_seq
  , bs.tag
  , bs.indicators
  , bs.subfield as f856u
  , ( select subfield from vger_subfields.ucladb_bib_subfield
      where record_id = bs.record_id
      and field_seq = bs.field_seq
      and tag = '856x'
      and rownum < 2
  ) as f856x
  from vger_subfields.ucladb_bib_subfield bs
  where tag = '856u'
  and indicators in ('40', '41')
  and subfield not like '%openurl.cdlib.org%'
)
, dups as (
  select *
  from d
  where (bib_id, f856u) in (
    select bib_id, f856u
    from d
    group by bib_id, f856u
    having count(*) > 1
  )
)
select
  dp.bib_id
, substr(bt.bib_format, 2, 1) as bib_lvl
, vger_support.unifix(bt.title_brief) as title
, dp.f856u
, dp.f856x
from dups dp
inner join bib_text bt on dp.bib_id = bt.bib_id
order by dp.bib_id, dp.f856u
;
--14781 fields
