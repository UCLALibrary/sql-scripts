/*  Law microform govdocs
    https://jira.library.ucla.edu/browse/RR-255

    CONTAINS 245 $h [microform] OR 337 $a microform
    (and)
    CONTAINS 910 $a govdocs
*/

with bibs as (
  select distinct record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where (tag = '245h' and subfield like '%[microform]%')
  or (tag = '337a' and subfield = 'microform')
)
, govdocs as (
  select distinct record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '910a' and subfield like '%govdocs%'
)
select
  b.bib_id
, l.location_code as loc
, bs.subfield as f245a
from bibs b
inner join govdocs gd on b.bib_id = gd.bib_id
inner join vger_subfields.ucladb_bib_subfield bs
  on b.bib_id = bs.record_id
  and bs.tag = '245a'
inner join bib_mfhd bm on b.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
--where l.location_code like 'lw%'
order by b.bib_id, l.location_code
;
-- 226881 bibs via 245h or 337a
-- 568 after filtering by 910
-- 538 after filtering by lw locations

