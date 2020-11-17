/*  Recalls for 12 months, by broad patron category.
    VBT-1706
*/

with d as (
  select 
    to_char(trunc(hra.create_date, 'month'), 'YYYY-MM') as mon
  , vger_support.get_simple_group(hra.patron_group_id) as patron_cat
  , hra.patron_id
  from hold_recall_archive hra
  --inner join patron_group pg on hra.patron_group_id = pg.patron_group_id
  inner join hold_recall_item_archive hri on hra.hold_recall_id = hri.hold_recall_id
  where hra.hold_recall_type = 'R'
  and hra.create_date >= to_date('20190301', 'YYYYMMDD') and hra.create_date < to_date('20200301', 'YYYYMMDD')
  --and hra.create_date >= to_date('20190701', 'YYYYMMDD') and hra.create_date < to_date('20200701', 'YYYYMMDD')
  --and hra.create_date >= to_date('20190101', 'YYYYMMDD') and hra.create_date < to_date('20200101', 'YYYYMMDD')
)
select
  mon
, patron_cat
, count(distinct patron_id) as patrons
, count(*) as requests
from d
group by mon, patron_cat
order by mon, patron_cat
;
