/*  Musical scores in Voyager
    https://jira.library.ucla.edu/browse/RR-217
    2016-10-07 akohler
    
    The report should include all records with Type (Leader/06) = c.
    For each record with Type = c we'd like a column including:

    Fixed field:
    Comp (008/18-19)
    Ctry (008/15-17)
    Dates [date1] (008/07-10)
    Dates [date2] (007/11-14)

    Variable fields:
    001 bib id
    045 1st indicator
    045 $b (repeatable subfield, first occurrence only)
    046 $k (repeatable field, first 046 $k only)
    046 $l (repeatable field, first 046 $l only)
    100 $acdq
    240 (uniform title field supplied by Ex Libris: 130/240/243 $adfgklmnoprs)
    245 (title field supplied by Ex Libris: 245 $abcfghknps)
*/

-- Create temp table as this is a long query needing export, which could time out otherwise
create table vger_report.tmp_rr_217 as
select 
  bt.bib_id
, substr(bt.field_008, 19, 2) as comp_form --008/18-19
, bt.place_code -- 008/15-17
, bt.begin_pub_date -- 008/07-10
, bt.end_pub_date -- 008/11-14
, (select min(replace(substr(indicators, 1, 1), ' ', '_')) from vger_subfields.ucladb_bib_subfield where record_id = bt.bib_id and tag like '045%') as f045_ind1
, vger_subfields.GetFirstSubfield(bt.bib_id, '045b') as f045b -- repeatable, take first only
, vger_subfields.GetFirstSubfield(bt.bib_id, '046k') as f046k -- repeatable, take first only
, vger_subfields.GetFirstSubfield(bt.bib_id, '046l') as f046l -- repeatable, take first only
-- Only want author from 100 field; use pre-built for convenience
, case
    when exists (select * from vger_subfields.ucladb_bib_subfield where record_id = bt.bib_id and tag like '100%')
    then vger_support.unifix(bt.author)
    else null
  end as author
, vger_subfields.GetFirstSubfield(bt.bib_id, '100d') as f100d
, vger_support.unifix(bt.uniform_title) as uniform_title
, vger_support.unifix(bt.title) as title
from ucladb.bib_text bt
where bt.bib_format like 'c%'
;
create index vger_report.ix_tmp_rr_217 on vger_report.tmp_rr_217 (bib_id);
-- 100621 rows

-- Then export it into Excel
select * from vger_report.tmp_rr_217 order by bib_id;

-- Drop the temp table
drop table vger_report.tmp_rr_217 purge;
