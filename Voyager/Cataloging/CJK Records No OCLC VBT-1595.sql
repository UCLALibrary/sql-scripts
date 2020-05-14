/*  CJK books with no OCLC number, in any location
    VBT-1595
*/

select
  bt.bib_id
, bt.language
, bm.suppress_in_opac as suppressed
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = bt.bib_id
) as locs
, case
    when exists (select * from vger_subfields.ucladb_bib_subfield where record_id = bt.bib_id and tag like '880%') 
    then 'YES'
    else null
  end as has_880
from bib_text bt
inner join bib_master bm on bt.bib_id = bm.bib_id
where bt.language in ('chi', 'jpn', 'kor')
and not exists (
  select *
  from bib_index
  where bib_id = bt.bib_id
  and index_code = '0350'
  and normal_heading like 'UCOCLC%'
)
--and bt.bib_id < 100000
order by bib_id
;
-- 20717 bibs with current specs, 20200514
