/*  Holdings records with multiple 852 $b.
    This *is* valid MARC - 852 can repeat, and each can have multiple $b - 
    but in Voyager 852 $b is location code and should not be repeated.
    Most seem to be miscoded 852 $i instead.
*/

with multiple_852b as (
  select
    record_id as mfhd_id
  , field_seq
  , subfield_seq
  , vger_subfields.GetFieldFromSubfields(record_id, field_seq, 'mfhd', 'ucladb') as f852
  from vger_subfields.ucladb_mfhd_subfield 
  where tag = '852b' 
  and record_id in (  
    select 
      record_id
    from vger_subfields.ucladb_mfhd_subfield 
    where tag = '852b' 
    group by record_id
    having count(*) > 1
  )
)
select distinct
  l.location_code
, substr(bt.bib_format, 2, 1) as format
, m.mfhd_id
, m.f852
from multiple_852b m
inner join mfhd_master mm on m.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join bib_mfhd bm on m.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
order by location_code, format, mfhd_id
;