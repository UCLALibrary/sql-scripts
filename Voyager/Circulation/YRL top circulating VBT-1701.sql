/*  Titles with most circulation, in YRL 2019.
    Look at holdings level, not individual items.
    VBT-1701
*/

with circ as (
  select circ_transaction_id, item_id, patron_id, charge_date
  from circ_transactions
  where charge_date between to_date('20190101', 'YYYYMMDD') and to_date('20200101', 'YYYYMMDD')
  and patron_group_id != 53 --GBS
  union all
  select circ_transaction_id, item_id, patron_id, charge_date
  from circ_trans_archive
  where charge_date between to_date('20190101', 'YYYYMMDD') and to_date('20200101', 'YYYYMMDD')
  and patron_group_id != 53 --GBS
)  
select 
  bt.bib_id
, vger_support.unifix(bt.title_brief) as title_brief
, replace(vger_support.unifix(ucladb.GetMarcField(bt.bib_id, 0, 0, '650', '', 'avxyz', '1')), 'NOT FOUND', null) as f650_1
, replace(vger_support.unifix(ucladb.GetMarcField(bt.bib_id, 0, 0, '650', '', 'avxyz', '2')), 'NOT FOUND', null) as f650_2
, replace(vger_support.unifix(ucladb.GetMarcField(bt.bib_id, 0, 0, '650', '', 'avxyz', '3')), 'NOT FOUND', null) as f650_3
, bt.language
, bt.place_code
, bt.pub_dates_combined as pub_dates
, substr(bt.bib_format, 2, 1) as bib_lvl
, to_char(mm.create_date, 'YYYY') as year_acq
, mm.display_call_no
, count(*) as circs
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join circ c on mi.item_id = c.item_id
where l.location_code = 'yr'
group by bt.bib_id, bt.title_brief, bt.language, bt.place_code, bt.pub_dates_combined, substr(bt.bib_format, 2, 1), to_char(mm.create_date, 'YYYY'), mm.display_call_no
having count(*) > 2
order by circs desc
;

