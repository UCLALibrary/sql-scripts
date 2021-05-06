/*  Queries for pre-1869 Japanese titles.
    RR-658
*/

-- Bibs only for MARC
select
  bt.bib_id
from bib_text bt
where bt.place_code = 'ja' 
and bt.begin_pub_date <= '1868'
order by bib_id
;

-- Specific info for Excel
select
  bt.bib_id
, bt.pub_dates_combined as pub_dates
, bt.language
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = bt.bib_id
) as locs
, ucladb.getbibtag(bt.bib_id, '300') as f300
, vger_support.unifix(bt.title) as title
, vger_subfields.get880field(bt.bib_id, '245') as title_880
from bib_text bt
where bt.place_code = 'ja' 
and bt.begin_pub_date <= '1868'
order by bt.bib_id
;
--1041 bibs, 1056 mfhds

