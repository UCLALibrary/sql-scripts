/*  Match cataloger names/initials from 910 against Voyager operators.
    For: Claudia Horning
    See: https://jira.library.ucla.edu/browse/VBT-450
*/

-- Create table vger_report.tmp_cataloger_initials via import of Excel file

select
  ci.cataloger_name
, ci.cataloger_initials
, ci.section_dept
, ( select operator_id
    from ucladb.operator
    where last_name || ', ' || first_name = ci.cataloger_name
      or  last_name || ', ' || first_name || ' ' || middle_initial  = ci.cataloger_name
      or  operator_id = ci.cataloger_initials
) as operator_id
from vger_report.tmp_cataloger_initials ci
where ci.end_employ is null
order by cataloger_name
;

