/*  Voyager bib and item data for a provided list of bibs which may have SRLF holdings.
    VBT-1779
*/

drop table vger_report.tmp_vbt1779 purge;
create table vger_report.tmp_vbt1779 (
  bib_id int not null primary key
)
;
-- 414044 rows; 347 bibs not found

select
  b.bib_id
, vger_support.get_oclc_number(b.bib_id) as oclc
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title_brief
, vger_support.unifix(bt.publisher) as publisher
, vger_support.unifix(bt.pub_place) as pub_place
, bt.pub_dates_combined
, mi.item_enum
, ib.item_barcode
, isc.item_stat_code_desc
/*
, ( select listagg(isc.item_stat_code_desc, ', ') within group (order by isc.item_stat_code_desc)
    from ucladb.item_stats ist
    inner join ucladb.item_stat_code isc on ist.item_stat_id = isc.item_stat_id
    where ist.item_id = i.item_id
) as item_stat_codes
*/
from vger_report.tmp_vbt1779 b
inner join ucladb.bib_text bt on b.bib_id = bt.bib_id
inner join ucladb.bib_mfhd bm on b.bib_id = bm.bib_id
inner join ucladb.mfhd_item mi on bm.mfhd_id = mi.mfhd_id
inner join ucladb.item i on mi.item_id = i.item_id
inner join ucladb.item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 --Active
inner join ucladb.location l on i.perm_location = l.location_id
left outer join ucladb.item_stats ist on i.item_id = ist.item_id
left outer join ucladb.item_stat_code isc on ist.item_stat_id = isc.item_stat_id and regexp_like(isc.item_stat_code, '[a-z][a-z][0-9]')
where l.location_code = 'sr'
order by b.bib_id, mi.item_enum
;
--326800 rows of item-level data

