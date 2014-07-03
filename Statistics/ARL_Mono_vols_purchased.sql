/*	Counts of monographic volumes purchased, as defined for annual ARL/UCOP statistics
	Uses prebuilt table vger_report.arl_stats with items for one fiscal year
	20070830 akohler
*/

-- CHANGE THE DATES FOR THE FISCAL YEAR
define FY_START = '20130701 000000';
define FY_END   = '20140630 235959';

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
select
	unit
,	(	select count(*)
		from vger_report.arl_stats s
		inner join ucladb.line_item_copy_status lics on s.mfhd_id = lics.mfhd_id
		--INNER JOIN ucladb.line_item li on lics.line_item_id = li.line_item_id
		inner join ucladb.invoice_line_item ili on lics.line_item_id = ili.line_item_id
		inner join ucladb.invoice i on ili.invoice_id = i.invoice_id
		inner join ucladb.invoice_status ist on i.invoice_status = ist.invoice_status
		where location_unit = u.unit
		and bib_level is not null -- due to voyager/oracle blank = NULL bug
		and bib_level not in ('b', 's')
		and i.invoice_status_date between To_Date('&FY_START', 'YYYYMMDD HH24MISS') and To_Date('&FY_END', 'YYYYMMDD HH24MISS')
		and ist.invoice_status_desc = 'Approved'
	) as in_unit
from units u
order by unit
;
