/*	Create working table with all data needed for item-level reports for a fiscal year:
	item id
	item type
	item owning loc stat code
	item perm loc
	hol type (LDR/06)
	hol 852 k
	hol 852 h
	hol 007
	bib lvl (LDR/07)
	hol id (for checking data)
	bib id (for checking data)

  Run as vger_report.
*/

-- CHANGE THE DATES FOR THE FISCAL YEAR
define FY_START = '20140701 000000';
define FY_END   = '20150630 235959';

-- Last year's data
drop table vger_report.arl_stats purge;

create table vger_report.arl_stats as
select /*+ ORDERED */
	i.item_id
,	mm.mfhd_id
,	bt.bib_id
,	it.item_type_code
,	it.item_type_name
, ic.item_stat_code
, ic.item_stat_code_desc
, case
    when ic.item_stat_code_desc in ('Exchange', 'Gift') then 'Gift'
    else 'Purchase'
  end as acq_type
,	oc.item_stat_code as ou_stat_code
,	oc.item_stat_code_desc as ou_stat_code_desc
,	oc.unit as owning_unit
,	l.location_code as item_perm_loc
,	l.unit as location_unit
,	mm.record_type as hol_type --LDR/06
,	mm.field_007 as hol_007
,	(select location_code from ucladb.location where location_id = mm.location_id) as mfhd_loc
,	SubStr(bt.bib_format, 2, 1) as bib_level
,	(select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852h' and rownum < 2) as hol_852h
,	(select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852k' and rownum < 2) as hol_852k
from ucladb.item i
inner join ucladb.item_type it on i.item_type_id = it.item_type_id
-- IJ filters out items for locations which should never be counted because they're not included in locations_by_unit (ILL, Reserves personal copies, "happening" locations); SRLF is included
inner join vger_support.locations_by_unit l on i.perm_location = l.location_id
inner join ucladb.mfhd_item mi on i.item_id = mi.item_id
inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
left outer join ucladb.item_stats istacq
  on i.item_id = istacq.item_id
  and istacq.item_stat_id in (select item_stat_id from ucladb.item_stat_code where item_stat_code between '500' and '599')
left outer join ucladb.item_stat_code ic
  on istacq.item_stat_id = ic.item_stat_id
left outer join ucladb.item_stats istsr
  on i.item_id = istsr.item_id
  and istsr.item_stat_id in (select item_stat_id from ucladb.item_stat_code where item_stat_code_desc like '*%')
left outer join vger_support.owning_codes_by_unit oc on istsr.item_stat_id = oc.item_stat_id
where i.create_date between To_Date('&FY_START', 'YYYYMMDD HH24MISS') and To_Date('&FY_END', 'YYYYMMDD HH24MISS')
;

create index vger_report.ix_arl_stats_location_unit on vger_report.arl_stats(location_unit);
create index vger_report.ix_arl_stats_owning_unit on vger_report.arl_stats(owning_unit);

-- 281958 rows for 2005/2006; 293952 for 2006/2007; 295073 for 2007/2008; 291262 2008/2009; 251581 2009/2010; 259610 2010/2011
-- 234652 2011/2012
-- 214672 2012/2013
-- 216276 2013/2014
-- 208941 2014/2015
select count(distinct item_id) from vger_report.arl_stats; -- many boundwiths, so count distinct items


/*****  Things to check -or not... *****/
-- Items with multiple stat cats, probably errors
select * from vger_report.arl_stats 
where item_id in (
  select item_id from vger_report.arl_stats
  group by item_id, mfhd_id, bib_id
  having count(*) > 1
)
order by item_id;

-- items with no units (location or owning) won't be counted
SELECT item_stat_code_desc, Count(*) FROM vger_report.arl_stats WHERE location_unit IS NULL AND owning_unit IS NULL GROUP BY item_stat_code_desc;
-- details: all pdacq items, in 2012/2013 at least
select * from vger_report.arl_stats where location_unit is null and owning_unit is null and mfhd_loc not in ('pdacq');
select item_perm_loc, count(*) as num from vger_report.arl_stats where location_unit is null and owning_unit is null group by item_perm_loc;

-- items which should be counted but aren't - apparently all SRLF errors
-- 2010-07-19: also pdacq items, which should not be counted (and aren't)
SELECT (SELECT item_barcode FROM ucladb.item_barcode WHERE item_id = s.item_id AND barcode_status = 1) AS barcode
, item_id, mfhd_id, bib_id, item_type_name, item_perm_loc, mfhd_loc
FROM vger_report.arl_stats s WHERE location_unit IS NULL AND owning_unit IS NULL AND item_stat_code_desc IS NULL
and mfhd_loc not in ('pdacq')
ORDER BY barcode
;
