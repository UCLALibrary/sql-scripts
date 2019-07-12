/*  Authority records with 'Dept.' (and variants) in 110/111, for cleanup project.
    VBT-1352
*/
with auths as (
  select distinct record_id, field_seq, substr(tag, 1, 3) as tag
  from vger_subfields.ucladb_auth_subfield
  where (tag like '110%' or tag like '111%')
  and (lower(subfield) like '%dept.%' or record_id = 277180) -- one exception for "Agricultural Dept"; auth 518564 has "Tax dept."
)
select
  au.record_id as auth_id
, (select subfield from vger_subfields.ucladb_auth_subfield where record_id = au.record_id and tag = '010a' and rownum < 2) as f010a
, (select subfield from vger_subfields.ucladb_auth_subfield where record_id = au.record_id and tag = '035a' and subfield like '(OCoLC)%' and rownum < 2) as f035a_OCLC
, (select subfield from vger_subfields.ucladb_auth_subfield where record_id = au.record_id and tag = '035a' and subfield like '(DLC)%' and rownum < 2) as f035a_DLC
, au.tag
, vger_subfields.GetFieldFromSubfields(au.record_id, au.field_seq, 'auth') as f1xx
from auths au
order by auth_id
;