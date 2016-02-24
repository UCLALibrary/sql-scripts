/*  Create working table of data for complex YRL weeding project.
    Jira: https://jira.library.ucla.edu/browse/RR-145
    2016-02-23 akohler
*/

drop table vger_report.rr145_yr purge;

create table vger_report.rr145_yr as
select
  bt.bib_id
, mm.mfhd_id
, bt.language
, bt.place_code
, (select replace(normal_heading, 'UCOCLC', '') from ucladb.bib_index where bib_id = bt.bib_id and index_code = '0350' and normal_heading like 'UCOCLC%' and rownum < 2) as oclc_num
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.imprint) as imprint
, l.location_code
, mm.normalized_call_no
, mm.display_call_no
, ib.item_id
, ib.item_barcode
, mi.item_enum
, i.copy_number
, isc.item_stat_code
, isc.item_stat_code_desc
, (select max(charge_date_only) from ucladb.circcharges_vw where item_id = i.item_id) as latest_charge_date
from ucladb.bib_text bt
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
-- YRL materials should have items but many older ones don't; let's see what we get if items are optional
left outer join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join ucladb.item i on mi.item_id = i.item_id
left outer join ucladb.item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 --Active
left outer join ucladb.item_stats ist on i.item_id = ist.item_id
left outer join ucladb.item_stat_code isc on ist.item_stat_id = isc.item_stat_id
where bt.bib_format in ('am', 'tm') -- LDR/06-07 (Condition #1)
and bt.begin_pub_date between '1923' and '1969' -- 008/07-10 (Condition #7)
and bt.date_type_status in ('e', 'q', 'r', 's', 't') -- 008/06 (Condition #7)
and l.location_code in ('yr', 'yr*', 'yr**', 'yr***') -- (Condition #3)
and not exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852x' and subfield like '%do not withdraw%') -- (Condition #4)
and not exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and regexp_like(tag, '86[6-8]')) -- (Condition #2)
and not exists (select * from ucladb.mfhd_item where mfhd_id = mm.mfhd_id and item_enum is not null) -- (Condition #2)
and not exists (select * from ucladb.circcharges_vw where item_id = i.item_id and charge_date_only >= to_date('20110101', 'YYYYMMDD')) -- (Condition #8)
;
create index vger_report.ix_rr145_yr on vger_report.rr145_yr (bib_id, mfhd_id);
create index vger_report.ix_rr145_yr_cn on vger_report.rr145_yr (mfhd_id, normalized_call_no);

grant select on vger_report.rr145_yr to ucla_preaddb;

select count(*) from vger_report.rr145_yr;
-- 138039 rows 2016-02-23
-- 2099 rows have no item data...

select mfhd_id, count(*) as num from vger_report.rr145_yr group by mfhd_id having count(*) > 1 order by num desc;
-- 9769 mfhds have multiple items, apparently due to multiple copies.  Example mfhds: 1643397, 1295545, 3634836

/*  Query for data wanted in report.
    Find YRL records (from working table) which
    * have specific call number range(s)
    * are linked to bibs which also have sr holdings
    * sr items don't have certain item stat codes for ownership
*/

with other_holdings as (
  select
    yr2.bib_id
  , mm2.mfhd_id
  , l2.location_code
  from vger_report.rr145_yr yr2
  inner join ucladb.bib_mfhd bm2 on yr2.bib_id = bm2.bib_id
  inner join ucladb.mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
  inner join ucladb.location l2 on mm2.location_id = l2.location_id
  where l2.location_code not like 'sr%'
  and l2.location_code not like 'yr%'
)
select
  yr.location_code
, yr.display_call_no
, yr.bib_id
, yr.mfhd_id
, yr.author
, yr.title
, yr.imprint
, yr.place_code
, yr.language
, yr.oclc_num
, yr.item_barcode
, yr.copy_number
, yr.item_stat_code_desc as yr_item_stat_code_desc
, isc.item_stat_code_desc as sr_item_stat_code_desc
, vger_support.get_all_item_status(i.item_id) as sr_item_status
, case
    when exists (select * from other_holdings where bib_id = yr.bib_id)
    then 'Y'
    else null
  end as has_non_yr_sr
from vger_report.rr145_yr yr
-- Must have sr holdings on same bib
inner join ucladb.bib_mfhd bm on yr.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
-- sr holdings must have items, at least in practical sense
inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join ucladb.item i on mi.item_id = i.item_id
-- sr items should have stat codes but might not
left outer join ucladb.item_stats ist on i.item_id = ist.item_id
left outer join ucladb.item_stat_code isc on ist.item_stat_id = isc.item_stat_id
where l.location_code = 'sr'
-- sr items might have no stat code so check for null as well as unwanted values
and (   isc.item_stat_code is null
    or  isc.item_stat_code not in ('sr1', 'uk1', 'uk2', 'uv1', 'uv2', 'ui1', 'ui0', 'ui9', 'ui2', 'ur1', 'ur2', 'ub1', 'ub2', 'uc1', 'uc2', 'ud1', 'ud0', 'ud2', 'us1', 'us2')
)
-- Plug in call number range(s) below, as desired.  LC call numbers are assumed.
-- Assume call number ranges should include all of the given class, e.g.,
-- a request for B77-BD431 means B77 through BD431.99999999 Z999.9999 - everything below BD432 - so round end of range up accordingly.
and (     yr.normalized_call_no between vger_support.NormalizeCallNumber('BD77') and vger_support.NormalizeCallNumber('BD432')
      or  yr.normalized_call_no between vger_support.NormalizeCallNumber('DS1') and vger_support.NormalizeCallNumber('DS147')
      or  yr.normalized_call_no between vger_support.NormalizeCallNumber('DS147') and vger_support.NormalizeCallNumber('DS921.93')
      or  yr.normalized_call_no between vger_support.NormalizeCallNumber('HQ759') and vger_support.NormalizeCallNumber('HV7292')
      or  yr.normalized_call_no between vger_support.NormalizeCallNumber('JA71') and vger_support.NormalizeCallNumber('JK276')
      or  yr.normalized_call_no between vger_support.NormalizeCallNumber('JN4461') and vger_support.NormalizeCallNumber('JX2')
      or  yr.normalized_call_no between vger_support.NormalizeCallNumber('PJ3501') and vger_support.NormalizeCallNumber('PJ9402')
      or  yr.normalized_call_no between vger_support.NormalizeCallNumber('PM987') and vger_support.NormalizeCallNumber('PN5356')
      or  yr.normalized_call_no between vger_support.NormalizeCallNumber('PQ5') and vger_support.NormalizeCallNumber('PQ8172')
)
order by yr.location_code, yr.normalized_call_no, yr.copy_number
;

