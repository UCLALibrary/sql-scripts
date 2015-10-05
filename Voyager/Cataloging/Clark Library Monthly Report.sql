/*  Cataloging report for Clark Library.
    This is the pure SQL; Analyzer version is modified to use parameter prompt for month.
    Jira: RR-107
    2015-10-05 akohler
*/
-- last_month is derived from today: go to start of this month, go back one day, truncate to month.
with last_month as (
  select to_char(trunc(trunc(sysdate, 'month') - 1, 'month'), 'YYYYMM') as last_month from dual
)
select distinct
  b.bib_id
, sf.field_seq
, substr(sf.tag, 1, 3) as tag
-- Get fields with no subfield delimiters or codes
, vger_subfields.GetFieldFromSubfields(b.bib_id, sf.field_seq, 'bib', 'ucladb', '') as field
from last_month, vger_report.cat_948_base_rpt b
left outer join vger_subfields.ucladb_bib_subfield sf
  on b.bib_id = sf.record_id
where b.s948a like 'clk%'
-- Use last month (the one before the current one...) by default, otherwise use what the user selected
--and b.s948c like decode(#prompt('p_month')#, 'LAST_MONTH', last_month.last_month, #prompt('p_month')#) || '%'
and b.s948c like last_month.last_month || '%'
-- Fields: 001, 090, 099, 1xx, 245, 245, 26x, 300, 5xx, 910, 948
and regexp_like(sf.tag, '^001|^090|^099|^1..|^245|^246|^26.|^300|^5..|^910|^948')
order by b.bib_id, sf.field_seq
;
--71

