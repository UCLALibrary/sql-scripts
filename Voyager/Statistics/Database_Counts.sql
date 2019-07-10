/*  Various database counts, occasionally requested by Leslie McMichael.
    Also requested by Mary Cliff in LBS for billing some units.
    
    All totals are cumulative.
    Set BEFORE_DATE as needed.
*/

define CREATED_BEFORE = '2019-07-01';

-- records by database
SELECT
	'Ethno' AS db
,	(SELECT Count(*) FROM ethnodb.auth_master where create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')) AS auths
,	(SELECT Count(*) FROM ethnodb.bib_master where create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')) AS bibs
,	(SELECT Count(*) FROM ethnodb.mfhd_master where create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')) AS holdings
FROM dual
UNION ALL
SELECT
	'Film/TV' AS db
,	(SELECT Count(*) FROM filmntvdb.auth_master where create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')) AS auths
,	(SELECT Count(*) FROM filmntvdb.bib_master where create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')) AS bibs
,	(SELECT Count(*) FROM filmntvdb.mfhd_master where create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')) AS holdings
FROM dual
UNION ALL
SELECT
	'UCLA' AS db
,	(SELECT Count(*) FROM ucladb.auth_master where create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')) AS auths
,	(SELECT Count(*) FROM ucladb.bib_master where create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')) AS bibs
,	(SELECT Count(*) FROM ucladb.mfhd_master where create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')) AS holdings
FROM dual
ORDER BY db;

-- holdings by unit
select
  l.unit
, count(*) as holdings
from vger_support.locations_by_unit l
inner join ucladb.mfhd_master mm on l.location_id = mm.location_id
where l.unit is not null
and mm.create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')
group by unit
order by unit
;

-- owning unit counts for SRLF
select
  isc.item_stat_code_desc
, count(*) as items
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join item i on mi.item_id = i.item_id
inner join item_stats ist on i.item_id = ist.item_id
inner join item_stat_code isc on ist.item_stat_id = isc.item_stat_id
where isc.item_stat_code_desc like '*%'
and l.location_code like 'sr%'
and i.create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')
group by isc.item_stat_code_desc
order by isc.item_stat_code_desc
;

