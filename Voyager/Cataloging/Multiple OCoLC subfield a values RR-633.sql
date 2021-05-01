/*  Bib records with multiple 035 $a (OCoLC), with different numbers.
    Accounts for 0-padding and letters and VBT-1778 WCM monos bug.
    RR-633
*/

with bibs as (
  select
    bi.bib_id
  , bi.display_heading
  -- Strip leading zeros
  , regexp_replace(normal_heading, '^0+', '') as oclc
  from bib_index bi
  where index_code = '035A'
  and display_heading like '(OCoLC)%'
  -- Convert all-digit strings to null, everything else is not null - selects only all-digit strings
  and replace(translate(normal_heading, '0123456789', '0000000000'), '0', '') is null
  --and bib_id < 1000000 --TESTING
)
select 
  b.*
, ( select substr(bib_format, 2, 1) from bib_text where bib_id = b.bib_id) as bib_lvl
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = b.bib_id
) as locs
from bibs b
where exists (
  select * from bibs where bib_id = b.bib_id and oclc != b.oclc
)
and not exists (
  select * from bibs where bib_id = b.bib_id and oclc = b.bib_id
)
order by bib_id, oclc
;
