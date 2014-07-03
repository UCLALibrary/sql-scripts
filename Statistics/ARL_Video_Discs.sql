/*	Counts of video discs, as defined for annual ARL/UCOP statistics
	Uses prebuilt table vger_support.arl_stats with items for one fiscal year
	20070830 akohler
*/

with units as (
select
	distinct unit
from vger_support.locations_by_unit
where unit is not null
and stats = 'Y'
union
select
	distinct unit
from vger_support.owning_codes_by_unit
where unit is not null
)
, unit_items as (
  select *
  from vger_report.arl_stats
  where item_type_name in ('Video Book', 'Video Journal')
  and mfhd_loc not like 'sr%'
  and	(	Upper(hol_852k) like '%VIDEODISC%'
    or	Upper(hol_852k) like '%DVD%'
  )
  and Upper(hol_852k) not like '%DVD%ROM%'
)
, srlf_items as (
  select *
  from vger_report.arl_stats
  where item_type_name in ('Video Book', 'Video Journal', 'SRLF Nonprint')
  and mfhd_loc like 'sr%'
  and	(	Upper(hol_852k) like '%VIDEODISC%'
    or	Upper(hol_852k) like '%DVD%'
  )
  and Upper(hol_852k) not like '%DVD%ROM%'
)
select
	u.unit
, (select count(distinct item_id) from unit_items where location_unit = u.unit and acq_type = 'Purchase') as in_unit_p
, (select count(distinct item_id) from unit_items where location_unit = u.unit and acq_type = 'Gift') as in_unit_g
, (select count(distinct item_id) from srlf_items where owning_unit = u.unit and acq_type = 'Purchase') as in_srlf_p
, (select count(distinct item_id) from srlf_items where owning_unit = u.unit and acq_type = 'Gift') as in_srlf_g
from units u
order by u.unit
;
