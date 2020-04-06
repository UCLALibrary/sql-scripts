/*  FATA records in TV collection with no 520, with some other filters
    VBT-1566
*/
with tv as (
  select 
    bs.record_id
  from vger_subfields.filmntvdb_bib_subfield bs
  where bs.tag = '901a'
  and bs.subfield = 'TV'
  and not exists (
    select * from vger_subfields.filmntvdb_bib_subfield 
    where record_id = bs.record_id
    and tag like '520%'
  )
)
, filters as (
  select record_id from tv
  minus
  select record_id from vger_subfields.filmntvdb_bib_subfield where tag like '245%' and upper(subfield) like '%KTLA%'
  minus
  select record_id from vger_subfields.filmntvdb_bib_subfield where tag like '245%' and upper(subfield) like '%TELENEWS%'
  minus
  select record_id from vger_subfields.filmntvdb_bib_subfield where tag like '245%' and upper(subfield) like '%HEARST NEWSREEL FOOTAGE%'
  -- Also exclude records with TELENEWS in the 730
  minus
  select record_id from vger_subfields.filmntvdb_bib_subfield where tag like '730%' and upper(subfield) like '%TELENEWS%'
)
select 
  f.record_id as bib_id
, vger_support.unifix(bt.title) as title
from filters f
inner join filmntvdb.bib_text bt on f.record_id = bt.bib_id
order by bib_id
;
-- 127282 TV bibs; 81513 lack 520 fields; 68422 after other filters, 68390; 68383 after adding 730 filter
