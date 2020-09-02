/*  Bibs with headings from local name authority records.
    VBT-1661
*/

-- Auths with 100/110/111, and no 010/040/645
with auths as (
  select distinct 
    record_id as auth_id
  , substr(s.tag, 1, 3) as tag
  , vger_subfields.getfieldfromsubfields(s.record_id, s.field_seq, 'auth') as name_fld
  from vger_subfields.ucladb_auth_subfield s
  where substr(s.tag, 1, 3) in ('100', '110', '111')
  and not exists (
    select *
    from vger_subfields.ucladb_auth_subfield
    where record_id = s.record_id
    and substr(tag, 1, 3) in ('010', '040', '645')
  )
  --and record_id < 25
)
select 
  count(distinct bh.bib_id)
  --*
from auths au
inner join auth_heading ah on au.auth_id = ah.auth_id
inner join bib_heading bh on ah.heading_id_pointer = bh.heading_id
where ah.heading_id_pointee = 0
and ah.reference_type = 'A'-- not sure this is needed, as all of these are Authorized AFAIK
and bh.suppress_in_opac = 'N'
--order by au.auth_id
;
-- 38691 auths; 77349 headings; 89556 bib_heading rows, 86086 distinct bibs, 85940 not suppressed
