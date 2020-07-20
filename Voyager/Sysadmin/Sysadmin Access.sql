-- SYSADMIN Access
select
  mp.master_profile_name
, o.operator_id
, o.last_name
, o.first_name
from ethnodb.master_profile mp
inner join ethnodb.master_operator mo on mp.master_profile_id = mo.master_profile_id
inner join ethnodb.operator o on mo.operator_id = o.operator_id
where o.operator_id not in ('SYSADMIN', 'Selfchk')
order by mp.master_profile_name, o.last_name, o.first_name
;

select
  mp.master_profile_name
, o.operator_id
, o.last_name
, o.first_name
from filmntvdb.master_profile mp
inner join filmntvdb.master_operator mo on mp.master_profile_id = mo.master_profile_id
inner join filmntvdb.operator o on mo.operator_id = o.operator_id
where o.operator_id not in ('SYSADMIN', 'Selfchk')
order by mp.master_profile_name, o.last_name, o.first_name
;

select
  mp.master_profile_name
, o.operator_id
, o.last_name
, o.first_name
from ucladb.master_profile mp
inner join ucladb.master_operator mo on mp.master_profile_id = mo.master_profile_id
inner join ucladb.operator o on mo.operator_id = o.operator_id
where o.operator_id not in ('SYSADMIN', 'Selfchk')
order by mp.master_profile_name, o.last_name, o.first_name
;
