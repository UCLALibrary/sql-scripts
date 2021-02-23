/*  Two sets of series authority records from Voyager for testing in Alma.
    VBT-1742
*/

-- Set 1
select distinct
  record_id as auth_id
from vger_subfields.ucladb_auth_subfield s
where (tag like '100%' or tag like '110%' or tag like '111%' or tag like '130%')
and exists (select * from vger_subfields.ucladb_auth_subfield where record_id = s.record_id and tag like '645%')
order by auth_id
;

-- Set 2
select distinct
  record_id as auth_id
from vger_subfields.ucladb_auth_subfield s
where (tag like '130%')
and exists (select * from vger_subfields.ucladb_auth_subfield where record_id = s.record_id and tag like '008%' and substr(subfield, 13, 1) = 'c') -- 008/12
order by auth_id
;