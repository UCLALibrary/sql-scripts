/*  Circ info for selected bib titles.
    Bib ids imported from provided excel file: 105 rows, 103 distinct values
      Dups: 7121740, 8266817
      RR-339
    20190123: Ran with new list of bib ids for RR-428, importing 137 distinct bib ids.
*/
select count(*), count(distinct bib_id) from vger_report.tmp_rr_339;

create index vger_report.ix_tmp_rr_339 on vger_report.tmp_rr_339 (bib_id);

select distinct 
  b.bib_id
, mm.mfhd_id
, vger_support.unifix(bt.title_brief) as title_brief
, bt.begin_pub_date as pub_date
, l.location_code
-- 852 $h only
, ucladb.GetMfhdSubfield(mm.mfhd_id, '852', 'h') as f852h
, ib.item_barcode as barcode
, ( select count(*)
    from ucladb.circcharges_vw
    where item_id = mi.item_id
    and charge_date_time between to_date('20180924', 'YYYYMMDD') and to_date('20181214 235959', 'YYYYMMDD HH24MISS')
) as charges
, i.historical_browses as "BROWSES*"
, ( select count(*)
    from ucladb.hold_recall_item_archive
    where item_id = mi.item_id
    and hold_recall_status_date between to_date('20180924', 'YYYYMMDD') and to_date('20181214 235959', 'YYYYMMDD HH24MISS')
    and hold_recall_type = 'R'
) as recalls
, ( select count(*)
    from ucladb.hold_recall_item_archive
    where item_id = mi.item_id
    and hold_recall_status_date between to_date('20180924', 'YYYYMMDD') and to_date('20181214 235959', 'YYYYMMDD HH24MISS')
    and hold_recall_type = 'H'
) as holds
, ( select coalesce(sum(reserve_charges), 0)
    from ucladb.reserve_item_history
    where item_id = mi.item_id
    and effect_date between to_date('20180924', 'YYYYMMDD') and to_date('20181214 235959', 'YYYYMMDD HH24MISS')
) as reserves
from vger_report.tmp_rr_339 b
inner join ucladb.bib_text bt on b.bib_id = bt.bib_id
inner join ucladb.bib_mfhd bm on b.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
-- holdings might not have items
left outer join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join ucladb.item i on mi.item_id = i.item_id
left outer join ucladb.item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 --Active
order by title_brief, pub_date, barcode
;

drop table vger_report.tmp_rr_339 purge;