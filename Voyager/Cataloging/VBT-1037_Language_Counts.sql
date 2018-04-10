/*  Report counts of bib records lacking 880 fields in specific languages.
    VBT-1037
*/

with langs as (
  select 
    lc.code
  , lc.language
  from vger_support.marc_language_codes lc
  where lc.code in ('chi', 'jpn', 'kor', 'ara', 'per', 'heb', 'yid', 'rus', 'tha')
)
select
  code
, language
, (select count(distinct bib_id) from vger_report.rpt_bibs_no880 where language = l.code) as needs_880
, (select count(bib_id) from bib_text where language = l.code) as bibs
from langs l
order by code
;

