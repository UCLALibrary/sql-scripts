with bibs as (
  -- All 690 fields with 2nd indicator 4 AND a $2 subfield present
  select record_id, field_seq, substr(tag, 1, 3) as tag, indicators
  from vger_subfields.ucladb_bib_subfield
  where tag = '6902'
  and indicators like '%4'
union
  -- All 691 fields with 2nd indicator #, 0, OR 7 (and other conditions handled in program)
  select record_id, field_seq, substr(tag, 1, 3) as tag, indicators
  from vger_subfields.ucladb_bib_subfield
  where tag like '691%'
  and substr(indicators, 2, 1) in (' ', '0', '7')
union
  -- All 693 fields with 2nd indicator 0
  select record_id, field_seq, substr(tag, 1, 3) as tag, indicators
  from vger_subfields.ucladb_bib_subfield
  where tag like '693%'
  and indicators like '%0'
union
  -- All 693 fields with 2nd indicator 4 (and other conditions handled in program)
  select record_id, field_seq, substr(tag, 1, 3) as tag, indicators
  from vger_subfields.ucladb_bib_subfield
  where tag like '693%'
  and indicators like '%4'
union
  select record_id, field_seq, substr(tag, 1, 3) as tag, indicators
  from vger_subfields.ucladb_bib_subfield
  where tag like '694%'
  and indicators like '%4'
union
  select record_id, field_seq, substr(tag, 1, 3) as tag, indicators
  from vger_subfields.ucladb_bib_subfield
  where tag like '695%'
  and indicators like '%4'
)
--11066 rows, test db
--select count(*), count(distinct record_id || '***' || field_seq), count(distinct record_id) from bibs;
select
  record_id as bib_id
, tag
, replace(indicators, ' ', '_') as ind
, vger_subfields.getfieldfromsubfields(record_id, field_seq) as fld
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = b.record_id
) as locs
, vger_support.get_oclc_number(b.record_id) as oclc
from bibs b
-- NOT to exclude fields linked to 880s
where not exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = b.record_id
  and field_seq = b.field_seq
  and tag = b.tag || '6'
)
order by bib_id, tag, field_seq
;
