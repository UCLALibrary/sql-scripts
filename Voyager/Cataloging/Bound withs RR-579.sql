/*  Bound-withs (bib 501), with some holdings / ownership info
    RR-579
*/

with bibs as (
  select distinct 
    record_id as bib_id
  , field_seq
  from vger_subfields.ucladb_bib_subfield
  where tag like '501%'
)
select 
  b.bib_id
, mm.mfhd_id
, l.location_code
, mm.display_call_no
-- All mfhd 852 $z, via listagg
, ( select listagg(subfield, ' *** ') within group (order by subfield_seq)
    from vger_subfields.ucladb_mfhd_subfield
    where tag = '852z'
    and record_id = mm.mfhd_id
) as f852_z
-- De-duped item owners for the given mfhd
, ( select listagg(item_stat_code_desc, ', ') within group (order by item_stat_code_desc)
    from (
      select distinct isc.item_stat_code_desc as item_stat_code_desc
      from mfhd_item mi
      inner join item_stats ist on mi.item_id = ist.item_id
      inner join item_stat_code isc on ist.item_stat_id = isc.item_stat_id
      where regexp_like(isc.item_stat_code, '^[a-z]..$')
      and mi.mfhd_id = mm.mfhd_id
    )
) as item_owners
-- All bib 505 $5 in the given field, via listagg
, ( select listagg(subfield, ' *** ') within group (order by subfield_seq)
    from vger_subfields.ucladb_bib_subfield
    where tag = '5015'
    and record_id = b.bib_id
    and field_seq = b.field_seq
) as f501_5
, vger_subfields.getfieldfromsubfields(b.bib_id, b.field_seq) as f501
from bibs b
inner join bib_mfhd bm on b.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
where mm.suppress_in_opac = 'N'
and l.suppress_in_opac = 'N'
order by b.bib_id, l.location_code, mm.mfhd_id
;
--17232 rows

