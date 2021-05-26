/*  Composite MARCIVE records using online version bib record.
    RR-660
*/

with bibs as (
  select distinct record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '910a'
  and subfield like '%marcive%'
)
, d as (
select distinct
  b.bib_id
, bt.bib_format
, case
    when regexp_like(bt.bib_format, '^[ef]') then substr(bt.field_008, 30, 1) --008/29
    else substr(bt.field_008, 24, 1) --008/23
end as form_008
, vger_support.unifix(bt.title) as title
from bibs b
inner join bib_text bt on b.bib_id = bt.bib_id
inner join bib_location bl on b.bib_id = bl.bib_id
inner join location l on bl.location_id = l.location_id
where l.location_code != 'in'
)
-- 502 form = o, out of nearly 20K
select
  bib_id
, substr(bib_format, 1, 1) as rec_type
, substr(bib_format, 2, 1) as bib_lvl
--, form_008
, vger_support.get_oclc_number(bib_id) as oclc
, ( select listagg(l.location_code, ', ') within group (order by l.location_code)
    from bib_location bl
    inner join location l on bl.location_id = l.location_id
    where bl.bib_id = d.bib_id
    and l.location_code != 'in'
) other_locs
, title
from d
--where bib_format like 'e%' or bib_format like 'f%' --form_008 = 'o'
where form_008 = 'o'
order by bib_id
;