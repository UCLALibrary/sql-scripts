/*  Basic info associated with SPAC EFL
    RR-481
*/
with bibs as (
  select *
  from vger_subfields.ucladb_bib_subfield bs
  where bs.tag = '901a'
  and bs.subfield = 'EFL'
)
select 
  bt.bib_id
, bt.isbn
, vger_support.get_oclc_number(b.record_id) as oclc
, ( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from ucladb.bib_location bl
    inner join ucladb.location l2 on bl.location_id = l2.location_id
    where bl.bib_id = b.record_id
) as all_locs
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title_brief
from bibs b
inner join bib_text bt on b.record_id = bt.bib_id
order by bib_id
;
-- 401 bibs



