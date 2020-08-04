/*  Map records from MARCIVE
*/
with maps as (
  select bib_id
  from bib_text
  where regexp_like(bib_format, '^[ef]')
)
--select count(*) from maps; -- 43783
select count(distinct m.bib_id) as bibs
from maps m
inner join bib_master bm on m.bib_id = bm.bib_id
inner join vger_subfields.ucladb_bib_subfield bs 
  on m.bib_id = bs.record_id
  and bs.tag = '910a'
  and bs.subfield like 'marcive%'
where bm.create_date between to_date('20190701', 'YYYYMMDD') and to_date('20200701', 'YYYYMMDD')
;
-- 7826; 387 created in 2019-2020

