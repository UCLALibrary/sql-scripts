-- Stats for work done by Paul Priebe, requested by Paul annually
define start_date = '20150701';
define end_date   = '20160701';

-- All bib records
select 
  'Bibs' as stat, count(distinct bib_id) as records
from bib_history
where operator_id = 'ppriebe'
and action_date between to_date('&start_date', 'YYYYMMDD') and to_date('&end_date', 'YYYYMMDD')
union all
-- All auth records
select 
  'All auths' as stat, count(distinct auth_id) as records
from auth_history ah
where operator_id = 'ppriebe'
and action_date between to_date('&start_date', 'YYYYMMDD') and to_date('&end_date', 'YYYYMMDD')
union all
-- Name-only auth records (certain 1xx fields)
select 
  'Name auths' as stat, count(distinct auth_id) as records
from auth_history ah
where operator_id = 'ppriebe'
and action_date between to_date('&start_date', 'YYYYMMDD') and to_date('&end_date', 'YYYYMMDD')
and exists (
  select * 
  from vger_subfields.ucladb_auth_subfield
  where record_id = ah.auth_id
  and (tag like '100%' or tag like '110%' or tag like '111%' or tag like '130%')
)
;
