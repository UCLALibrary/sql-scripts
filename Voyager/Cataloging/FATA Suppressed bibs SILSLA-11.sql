/*  FATA suppressed bib records.
    SILSLA-11
*/

select 
  br.bib_id
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from filmntvdb.bib_location bl
    inner join filmntvdb.location l on bl.location_id = l.location_id
    where bl.bib_id = br.bib_id
) as locs
from filmntvdb.bib_master br
where suppress_in_opac = 'Y'
order by bib_id
;
-- 5917