/*  Bib 856 fields with $a
    RR-625
*/
select 
  bs.record_id as bib_id
, substr(bt.bib_format, 2, 1) as bib_lvl
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = bs.record_id
) as locs
, bs.indicators
, bs.subfield as f856a
, vger_subfields.getfieldfromsubfields(bs.record_id, bs.field_seq) as f856
from vger_subfields.ucladb_bib_subfield bs
inner join bib_text bt on bs.record_id = bt.bib_id
where bs.tag = '856a'
order by bib_id
;