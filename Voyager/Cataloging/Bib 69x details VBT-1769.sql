/*  Query to get data for various bib 69x reports.
    Change tag & indicators, and enable/disable $2 subquery as needed.
    VBT-1769
*/

-- Confirmed that all 69x have $a
select 
  substr(tag, 1, 3) as tag
, replace(substr(indicators, 2, 1), ' ', '#') as ind2
, vger_subfields.getfieldfromsubfields(bs.record_id, bs.field_seq) as fld
, bs.record_id as bib_id
, vger_support.get_oclc_number(bs.record_id) as oclc
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = bs.record_id
) as locs
from vger_subfields.ucladb_bib_subfield bs
-- Change these as needed
where tag = '695a'
and indicators like '%4'
--and exists (select * from vger_subfields.ucladb_bib_subfield where record_id = bs.record_id and field_seq = bs.field_seq and tag like '%2' and subfield = 'local')
order by bs.record_id, bs.field_seq
;

