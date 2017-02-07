/*  Various record counts for possible Zepheira projects.
    Keeping SQL in case this leads to extraction requests.
    https://jira.library.ucla.edu/browse/VBT-767
*/

-- 1) bibliographic records with the Leader/Bib Level (07) = m (monograph) and an associated holdings record with 852 $b beginning with yrsp
select
  count(distinct bt.bib_id) as bibs
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
where l.location_code like 'yrsp%'
and bt.bib_format like '_m'
;
-- 243126 2017-02-07

-- 2) bibliographic records with Leader/Type of Record (06) = e (printed cartographic material) and a 6XX field containing $v Maps.
select
  count(distinct bt.bib_id) as bibs
from bib_text bt
where bt.bib_format like 'e%'
and exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bt.bib_id
  and tag like '6__v'
  and subfield = 'Maps.'
)
;
-- 522 Maps 35263 Maps. 2017-02-07

-- 3) bibliographic records with the Leader/Bib Level (07) = m AND (651 $a containing $a "Los Angeles (Calif.)" OR a 650 containing "$z California $z Los Angeles")
select
  count(distinct bt.bib_id) as bibs
from bib_text bt
where bt.bib_format like '_m'
and 
( exists 
    (
      select * 
      from vger_subfields.ucladb_bib_subfield
      where record_id = bt.bib_id
      and tag = '651a'
      and subfield = 'Los Angeles (Calif.)'
    )
  or exists
    (
      select * 
      from vger_subfields.ucladb_bib_subfield bs1
      where bs1.record_id = bt.bib_id
      and bs1.tag = '650z'
      and bs1.subfield = 'California'
      and exists (
        select *
        from vger_subfields.ucladb_bib_subfield bs2
        where bs2.record_id = bs1.record_id
        and bs2.field_seq = bs1.field_seq
        and bs2.subfield_seq = bs1.subfield_seq + 1
        and bs2.subfield = 'Los Angeles'
      )
    ) -- end of OR 
) -- end of compound AND
;
-- 6187 2017-02-07

-- 4) bibliographic records with the Leader/Bib Level (07) = s (serial) and a 245 $a containing "Los Angeles"
select
  count(distinct bt.bib_id) as bibs
from bib_text bt
where bt.bib_format like '_s'
and exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = bt.bib_id
  and tag = '245a'
  and subfield like '%Los Angeles%'
)
;
-- 767 2017-02-07
