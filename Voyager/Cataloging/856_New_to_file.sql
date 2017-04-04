/*
1.  New to file URLs (for now, monthly; eventually we might want a weekly report)
Criteria: New Voyager records containing 856s, in ucladb only.
Divisions: Separate reports for monographs and non-monographs.
Subdivide report: (1) with 1st indicator = 4; (2) all other 856s (Note: Entries lacking 1st indicator 4 or 7 just need to be deleted; those with 1st indicator 7 need to be evaluated and edited or deleted.)

Send to erdb-maint@library.ucla.edu

Exclude:
856 $3 containing any of these strings:
1. Bibliographic description
2. Book review
3. Contributor biographical information
4. Finding aid
5. Official government website
6. Publisher description
7. Report on which this opinion is based
8. Sample text
9. Table of contents
10. Title page, table of contents, foreword
11. TOC (Will ask the appropriate people to consider a change in the Casalini specs)

856 with $x CDL or $x UCLA Law

856 with $z UCLA Law School use only

856 with $u containing
1. purl.access.gpo.gov
2. bibpurl.oclc.org
3. uclibs.org
4. repositories.cdl.org
5. openurl.cdlib.org
6. hdl.loc.gov
7. purl.fdlp.gov

*/

-- 2017-04-04: Now in Analyzer at: Cataloging -> Bib 856 new to file (monthly)
-- Scheduled to run first Tuesday of month at 3 pm Pacific
WITH bibs AS (
	SELECT bib_id
	FROM ucladb.bib_history
	WHERE action_type_id = 1 --create
  -- last_month is derived from today: go to start of this month, go back one day, truncate to month.
  and trunc(action_date, 'month') = trunc(trunc(sysdate, 'month') - 1, 'month')
)
, tmp_urls as (
SELECT /*+ ORDERED */
	s.record_id
,	s.record_id || ':' || s.field_seq AS handle
,	SubStr(s.indicators, 1, 1) AS ind1
,	s.tag
,	s.field_seq
,	Upper(s.subfield) AS subfield
FROM vger_subfields.ucladb_bib_subfield s
WHERE s.tag LIKE '856%'
AND EXISTS (SELECT * FROM bibs WHERE bib_id = s.record_id)
)
--select count(*) from tmp_urls -- 18157
, good_856 as (
  select record_id, field_seq, ind1, handle from tmp_urls
  minus
  select record_id, field_seq, ind1, handle from tmp_urls
    where tag = '856x'
    and subfield in ('CDL', 'UCLA LAW')
  minus
  select record_id, field_seq, ind1, handle from tmp_urls
    where tag = '856z'
    and subfield = 'UCLA LAW SCHOOL USE ONLY'
  minus
  select record_id, field_seq, ind1, handle from tmp_urls
    where tag = '856u'
    AND (	subfield LIKE '%BIBPURL.OCLC.ORG%'
      OR	subfield LIKE '%PURL.FDLP.GOV%'
      OR	subfield LIKE '%HDL.LOC.GOV%'
      OR	subfield LIKE '%OPENURL.CDLIB.ORG%'
      OR	subfield LIKE '%PURL.ACCESS.GPO.GOV%'
      OR	subfield LIKE '%REPOSITORIES.CDL.ORG%'
      OR	subfield LIKE '%UCLIBS.ORG%'
    ) -- 856u subfield
  minus
  select record_id, field_seq, ind1, handle from tmp_urls
    where tag = '8563'
    AND (	subfield LIKE '%BIBLIOGRAPHIC DESCRIPTION%'
      OR	subfield LIKE '%BOOK REVIEW%'
      OR	subfield LIKE '%CONTRIBUTOR BIOGRAPHICAL INFORMATION%'
      OR	subfield LIKE '%FINDING AID%'
      OR	subfield LIKE '%OFFICIAL GOVERNMENT WEBSITE%'
      OR	subfield LIKE '%PUBLISHER DESCRIPTION%'
      OR	subfield LIKE '%REPORT ON WHICH THIS OPINION IS BASED%'
      OR	subfield LIKE '%SAMPLE TEXT%'
      OR	subfield LIKE '%TABLE OF CONTENTS%'
      OR	subfield	= 'TOC' -- table of contents, in Casalini records
    ) -- 8563 subfield
)
select
	case
		when SubStr(bt.bib_format, 2, 1) in ('i', 's') then 'serial'
		else 'mono'
	end as format
,	ind1
,	bt.bib_id
,	(SELECT subfield FROM vger_subfields.ucladb_bib_subfield WHERE record_id = bt.bib_id AND tag = '035a' AND subfield LIKE '(OCoLC)%' AND ROWNUM < 2) AS oclc_number
,	vger_support.UniFix(bt.title_brief) AS title_brief
,	vger_subfields.GetFieldFromSubfields(tmp.record_id, tmp.field_seq) AS F856
,	(SELECT subfield FROM vger_subfields.ucladb_bib_subfield WHERE record_id = bt.bib_id AND tag = '910a' AND ROWNUM < 2) AS F910a
from good_856 tmp
inner join ucladb.bib_text bt on tmp.record_id = bt.bib_id
order by format, ind1, bib_id
;

