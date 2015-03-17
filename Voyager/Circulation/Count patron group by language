Enter file contents here
select
  cc.patron_group_name
, count(*) as num
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join circcharges_vw cc on mi.item_id = cc.item_id
where bt.language in ('chi', 'jpn', 'kor')
and l.location_code like 'ea%'
and cc.charge_date_only between to_date('20100701', 'YYYYMMDD') and to_date('20110630', 'YYYYMMDD')
group by cc.patron_group_name
order by num desc
;

