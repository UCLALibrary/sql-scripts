/*  Physical collection growth rates.
    UCLA-owned items added each month in the last 5+ fiscal years.
    VBT-1747
*/

with items as (
  select item_id, create_date
  from item
  where create_date between to_date('20150701', 'YYYYMMDD') and to_date('20210228 235959', 'YYYYMMDD HH24MISS')
)
, non_uc as (
  select ist.item_id
  from item_stats ist
  inner join item_stat_code isc on ist.item_stat_id = isc.item_stat_id
  where isc.item_stat_code in ('ub1', 'ub2', 'uc1', 'uc2', 'ud0', 'ud1', 'ud2', 'ui0', 'ui1', 'ui2', 'ui9', 'uk1', 'uk2', 'um2', 'ur1', 'ur2', 'us1', 'us2', 'uv1', 'uv2')
)
, ucla_items as (
  select 
    item_id
  , case 
      when create_date between to_date('20150701', 'YYYYMMDD') and to_date('20160630 235959', 'YYYYMMDD HH24MISS') then 'FY 2015/2016'
      when create_date between to_date('20160701', 'YYYYMMDD') and to_date('20170630 235959', 'YYYYMMDD HH24MISS') then 'FY 2016/2017'
      when create_date between to_date('20170701', 'YYYYMMDD') and to_date('20180630 235959', 'YYYYMMDD HH24MISS') then 'FY 2017/2018'
      when create_date between to_date('20180701', 'YYYYMMDD') and to_date('20190630 235959', 'YYYYMMDD HH24MISS') then 'FY 2018/2019'
      when create_date between to_date('20190701', 'YYYYMMDD') and to_date('20200630 235959', 'YYYYMMDD HH24MISS') then 'FY 2019/2020'
      when create_date between to_date('20200701', 'YYYYMMDD') and to_date('20210228 235959', 'YYYYMMDD HH24MISS') then 'FY 2020/2021'
      else null
    end as fy
  from items
  where not exists (
    select * from non_uc where item_id = items.item_id
  )
)
--select count(distinct i.item_id) 
select 
  i.fy
--, case when substr(bt.bib_format, 2, 1) = 's' then 'serial' else 'mono' end as format
, sum(case when substr(bt.bib_format, 2, 1) = 's' then 1 else 0 end) as serials
, sum(case when substr(bt.bib_format, 2, 1) != 's' then 1 else 0 end) as monos
, count(distinct i.item_id) as items
from ucla_items i
inner join bib_item bi on i.item_id = bi.item_id
inner join bib_text bt on bi.bib_id = bt.bib_id
group by fy
order by fy
 -- 646666 after
;
