/*	Counts of serials currently received, as defined for annual ARL/UCOP statistics
	20070830 akohler
	20070924 akohler: revised to split electronic serials by CDL/UCLA
  20090203 akohler: revised to meet new (2007/2008) ARL requirements
*/

-- CHANGE THE DATES FOR THE FISCAL YEAR
define FY_START = '20130701 000000';
define FY_END   = '20140630 235959';

-- Temp table of all serial data for multiple reports
drop table vger_report.tmp_serials purge;
create table vger_report.tmp_serials as
select
	bt.bib_id
,	bt.bib_format
, bt.field_008 as bib_008
,	mm.mfhd_id
,	mm.field_008 as mfhd_008
,	l.location_code
--,	l.unit AS location_unit --slow
,	(select unit from vger_support.locations_by_unit where location_id = l.location_id) as location_unit
,	Upper(sf_852x.subfield) as f852x
,	Upper(sf_866x.subfield) as f866x
,	pot.po_type_desc
,	pos.po_status_desc
,	lit.line_item_type_desc
,	lis.line_item_status_desc
from ucladb.bib_text bt
inner join ucladb.bib_master bm on bt.bib_id = bm.bib_id
inner join ucladb.bib_mfhd bmd on bm.bib_id = bmd.bib_id
inner join ucladb.mfhd_master mm on bmd.mfhd_id = mm.mfhd_id
--inner join vger_support.locations_by_unit l on mm.location_id = l.location_id --slow
inner join ucladb.location l on mm.location_id = l.location_id
left outer join ucladb.line_item_copy_status lics on mm.mfhd_id = lics.mfhd_id
left outer join ucladb.line_item_status lis on lics.line_item_status = lis.line_item_status
left outer join ucladb.line_item li on lics.line_item_id = li.line_item_id
left outer join ucladb.line_item_type lit on li.line_item_type = lit.line_item_type
left outer join ucladb.purchase_order po on li.po_id = po.po_id
left outer join ucladb.po_status pos on po.po_status = pos.po_status
left outer join ucladb.po_type pot on po.po_type = pot.po_type
left outer join vger_subfields.ucladb_mfhd_subfield sf_852x
	on mm.mfhd_id = sf_852x.record_id
	and sf_852x.tag = '852x'
left outer join vger_subfields.ucladb_mfhd_subfield sf_866x
	on mm.mfhd_id = sf_866x.record_id
	and sf_866x.tag = '866x'
where bt.bib_format in ('ab', 'as', 'bs', 'cs', 'es', 'gs', 'is', 'ks', 'ms', 'nb', 'ns', 'os', 'ps', 'tb', 'ts')
and bt.end_pub_date = '9999'
and bm.suppress_in_opac = 'N'
and bm.create_date < to_date('&FY_START', 'YYYYMMDD HH24MISS')
;

create index vger_report.ts_ix_bib_id on vger_report.tmp_serials (bib_id);
create index vger_report.ts_ix_unit on vger_report.tmp_serials (location_unit);

-- Print titles (not subscriptions!) by reporting unit
WITH units AS (
SELECT
	DISTINCT location_unit
FROM vger_report.tmp_serials
WHERE location_unit IS NOT NULL
AND EXISTS (SELECT * FROM vger_support.locations_by_unit WHERE unit = tmp_serials.location_unit AND stats = 'Y')
)
SELECT
	location_unit AS unit
,	(	SELECT Count(DISTINCT bib_id) FROM (
			SELECT
				bib_id
			,	location_unit
			FROM vger_report.tmp_serials ts
			WHERE NOT EXISTS (SELECT * FROM vger_report.tmp_serials WHERE bib_id = ts.bib_id AND location_code = 'in')
			AND NOT EXISTS (SELECT * FROM ucladb.line_item WHERE bib_id = ts.bib_id)
			AND SubStr(mfhd_008, 7, 1) = '4' -- mfhd 008/06 type of acq: currently received
			AND (
					f852x LIKE '%SUPPLIES%'
				 OR	f852x LIKE '%DEPOSITORY%'
				 OR	f866x LIKE '%SUPPLIES%'
				 OR	f866x LIKE '%DEPOSITORY%'
			)
			UNION ALL
			SELECT
				bib_id
			,	location_unit
			FROM vger_report.tmp_serials ts
			WHERE NOT EXISTS (SELECT * FROM vger_report.tmp_serials WHERE bib_id = ts.bib_id AND location_code = 'in')
			AND po_type_desc IN ('Continuation', 'Depository', 'Exchange', 'Gift')
			AND po_status_desc IN ('Approved/Sent', 'Received Partial')
			AND line_item_type_desc IN ('Membership', 'Multi-part', 'Standing Order', 'Subscription')
			AND line_item_status_desc NOT IN ('Cancelled')
		) tmp
		WHERE location_unit = units.location_unit
	) AS titles
FROM units
ORDER BY unit
;

/***** ARL 2007/2008 new definitions/reports 20090203 *****/
-- 4a. Number of serial titles currently purchased, in nonintersecting sets "electronic" and "print (aka not electronic)"
SELECT
  Count(DISTINCT ts.bib_id) AS titles
--,	Count(*) AS subscriptions
FROM vger_report.tmp_serials ts
WHERE po_type_desc IN ('Continuation')
AND po_status_desc IN ('Approved/Sent', 'Received Partial')
AND line_item_type_desc IN ('Membership', 'Multi-part', 'Standing Order', 'Subscription')
AND line_item_status_desc NOT IN ('Cancelled') --and line_item_status_desc is not null
/*** Uncomment AND/NOT EXISTS as needed for 4a.i and 4a.ii ***/
-- 4a.i electronic
--AND EXISTS (SELECT * FROM vger_report.tmp_serials WHERE bib_id = ts.bib_id AND location_code = 'in') 
-- 4a.ii print (non-electronic)
--AND NOT EXISTS (SELECT * FROM vger_report.tmp_serials WHERE bib_id = ts.bib_id AND location_code = 'in')
;

-- 4b. Number of serial titles currently received but not purchased, in nonintersecting sets:
-- 4b.i Consortial: by our definition, we have no non-paid consortial titles
-- 4b.ii Freely accessible
-- 4b.iii Print (and other format) - Exchanges, gifts, etc.
-- 4b.iv Government documents: 008/28 in (acfilmosz)
-- another view:
---- Gov docs (print & electronic): 4b.iv
---- Non gov docs
------ print: 4b.iii
------ electronic
-------- consortial: 4b.i
-------- freely accessible: 4b.ii

select
	count(distinct ts.bib_id) as titles
from vger_report.tmp_serials ts
where (
  ( po_type_desc in ('Depository', 'Exchange', 'Gift')
    and po_status_desc in ('Approved/Sent', 'Received Partial')
    and line_item_type_desc in ('Membership', 'Multi-part', 'Standing Order', 'Subscription')
    and line_item_status_desc not in ('Cancelled')
  )
  or po_type_desc is null
)
-- Holdings edited in the last year, as surrogate for check-in
and exists (
  select * 
  from ucladb.mfhd_history
  where mfhd_id = ts.mfhd_id
  and action_date between to_date('&FY_START', 'YYYYMMDD HH24MISS') and to_date('&FY_END', 'YYYYMMDD HH24MISS')
  and operator_id not in ('lisprogram', 'marsloader', 'nomelvyl', 'promptcat', 'scploader', 'uclaloader', '(SYS: ACQ)')
)
/*** Uncomment sets of criteria as needed for 4b.ii/iii/iv ***/
-- 4b.ii non gov docs electronic freely accessible
and (substr(bib_008, 29, 1) not in ('a', 'c', 'f', 'i', 'l', 'm', 'o', 's', 'z') or substr(bib_008, 29, 1) is null)
and exists (select * from vger_report.tmp_serials where bib_id = ts.bib_id and location_code = 'in') --electronic
-- 4b.iii non gov docs print
--and (substr(bib_008, 29, 1) not in ('a', 'c', 'f', 'i', 'l', 'm', 'o', 's', 'z') or substr(bib_008, 29, 1) is null)
--and not exists (select * from vger_report.tmp_serials where bib_id = ts.bib_id and location_code = 'in') --print
-- 4b.iv gov docs bib 008/28, print & electronic
--and substr(bib_008, 29, 1) in ('a', 'c', 'f', 'i', 'l', 'm', 'o', 's', 'z')
;

/*
Obsolete(?) queries - not used in 2009-2010
-- Total in working set
select 
  count(distinct bib_id) as titles
, count(*) as subscriptions
from vger_report.tmp_serials;

-- Electronic serials: at least one internet holdings record exists
SELECT
	Count(DISTINCT bib_id) AS titles --24764 20070830; 27753 20080716
,	Count(*) AS subscriptions --not calculated 20070830; 27797 20080716
FROM vger_report.tmp_serials
WHERE location_code = 'in';

-- Divide up electronic by UCLA/CDL in bib 856 $x, for new CDL reporting requirement
SELECT
	s.subfield
,	Count(DISTINCT t.bib_id) AS num
FROM vger_report.tmp_serials t
LEFT OUTER JOIN vger_subfields.ucladb_bib_subfield s
	ON t.bib_id = s.record_id
	AND s.tag = '856x'
WHERE t.location_code = 'in'
GROUP BY s.subfield
;

-- For checking: electronic serials with both UCLA and CDL access (or neither)
SELECT *
FROM vger_report.tmp_serials t
WHERE t.location_code = 'in'
AND NOT EXISTS (SELECT * FROM vger_subfields.ucladb_bib_subfield WHERE record_id = t.bib_id AND tag = '856x' AND subfield = 'UCLA')
AND NOT EXISTS (SELECT * FROM vger_subfields.ucladb_bib_subfield WHERE record_id = t.bib_id AND tag = '856x' AND subfield = 'CDL')
;

-- Print-only titles with no PO but (supposedly) currently received, with certain words in note fields
SELECT
	Count(DISTINCT bib_id) AS titles --241 20070830; 266 20080716
,	Count(*) AS subscriptions --not calculated 20070830; 270 20080716
FROM vger_report.tmp_serials ts
WHERE NOT EXISTS (SELECT * FROM vger_report.tmp_serials WHERE bib_id = ts.bib_id AND location_code = 'in')
AND NOT EXISTS (SELECT * FROM line_item WHERE bib_id = ts.bib_id)
AND SubStr(mfhd_008, 7, 1) = '4' -- mfhd 008/06 type of acq: currently received
AND (
		f852x LIKE '%SUPPLIES%'
	 OR	f852x LIKE '%DEPOSITORY%'
	 OR	f866x LIKE '%SUPPLIES%'
	 OR	f866x LIKE '%DEPOSITORY%'
)
;

-- Print-only titles and subscriptions linked to open POs, based on PO and line item type/status
SELECT
	po_type_desc AS po_type
,	Count(DISTINCT ts.bib_id) AS titles --20481 20070830; 20038 20080716
,	Count(*) AS subscriptions --not calculated 20070830; 24142 20080716
FROM vger_report.tmp_serials ts
WHERE NOT EXISTS (SELECT * FROM vger_report.tmp_serials WHERE bib_id = ts.bib_id AND location_code = 'in')
AND po_type_desc IN ('Continuation', 'Depository', 'Exchange', 'Gift')
AND po_status_desc IN ('Approved/Sent', 'Received Partial')
AND line_item_type_desc IN ('Membership', 'Multi-part', 'Standing Order', 'Subscription')
AND line_item_status_desc NOT IN ('Cancelled')
GROUP BY po_type_desc
ORDER BY po_type
;

-- Electronic titles and subscriptions linked to open POs, based on PO and line item type/status
SELECT
	po_type_desc AS po_type
,	Count(DISTINCT ts.bib_id) AS titles --20481 20070830; 20038 20080716
,	Count(*) AS subscriptions --not calculated 20070830; 24142 20080716
FROM vger_report.tmp_serials ts
WHERE ts.location_code = 'in'
AND po_type_desc IN ('Continuation', 'Depository', 'Exchange', 'Gift')
AND po_status_desc IN ('Approved/Sent', 'Received Partial')
AND line_item_type_desc IN ('Membership', 'Multi-part', 'Standing Order', 'Subscription')
AND line_item_status_desc NOT IN ('Cancelled')
GROUP BY po_type_desc
ORDER BY po_type
;
*/