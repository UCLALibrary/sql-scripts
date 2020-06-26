/*  Duplicate OCLC numbers in FATA. 
    Includes OCLC IR numbers, evaluated separately from OCLC numbers.
    SILSLA-7
*/

with dups as (
  select
    normal_heading
  from filmntvdb.bib_index
  where index_code = '0350'
  and normal_heading not like 'UCOCLC%'
  and normal_heading not like 'ORION2%'
  group by normal_heading
  having count(*) > 1
)
select distinct
  display_heading
, ( select listagg(bib_id, ',') within group (order by bib_id)
    from filmntvdb.bib_index
    where index_code = '0350'
    and normal_heading = bi.normal_heading
) as bibs
from filmntvdb.bib_index bi
where normal_heading in (select normal_heading from dups)
order by display_heading
;
