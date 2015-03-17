Enter file contents here
select
  bt.language as lng
, count(*) as num
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join circcharges_vw cc on mi.item_id = cc.item_id
where bt.language in ('chi', 'jpn', 'kor')
and l.location_code like 'ea%'
and cc.charge_date_only between to_date('20130701', 'YYYYMMDD') and to_date('20140630', 'YYYYMMDD')
group by bt.language
order by bt.language;
