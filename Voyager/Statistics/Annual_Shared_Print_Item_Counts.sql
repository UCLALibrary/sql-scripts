/*
From John Riemer.  See Footprints 34171.
https://docs.library.ucla.edu/x/Y4gXB

Colleen and Sharon have requested that I come up with the statistics that show how many items we committed in FY2013
to two different Shared Print programs that CDL tracks, using the first attachment. 

I believe the specs below will capture what is needed.

(A) WEST Bronze—non SRLF [i.e. UCLA only]
Count all item records with Item Type ‘WEST Bronze' attached to holdings records with a 583 field containing subfield $f with ‘WEST Bronze'
AND 852 $b beginning with any location code characters other than ‘sr' <to exclude SRLF holdings that being separately reported>

<To narrow the figures to just FY2013 activity, I will need to subtract from your count in (A) 
what got reported for the first year of the project (22,150 in the second attachment). 
I don't believe we would be able to use the counting strategy you use for ARL stats, 
where we look for the date of creation of item records in Voyager falling into a particular fiscal year of interest. 
The reason is that these WEST archiving commitment are imposed on already-existing Voyager data that was created in earlier times.>

(B) Shared Print Monographic series
Count all item records with Item Type ‘Shared Print in Place' attached to holdings records with a 583 field containing subfield $f with ‘UCL Shared Print'
AND another 583 subfield $f containing the substring ‘Monographic Series' AND 852 $b beginning with any location code characters other than ‘sr'

<This is the first fiscal year we have been asked to count this category of Shared Print. 
In subsequent years I likely will need to subtract the number of items reported in prior years to deduce the most recent fiscal year total.>
*/

-- (A) WEST Bronze—non SRLF [i.e. UCLA only]
with mfhds as (
  select record_id as mfhd_id
  from vger_subfields.ucladb_mfhd_subfield
  where tag = '583f'
  and subfield = 'WEST Bronze'
)
select 
  count(*) as num
from mfhds m
inner join ucladb.mfhd_master mm on m.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.mfhd_item mi on m.mfhd_id = mi.mfhd_id -- direct from m (small set)
inner join ucladb.item i on mi.item_id = i.item_id
inner join ucladb.item_type it on i.item_type_id = it.item_type_id
where l.location_code not like 'sr%'
and it.item_type_name = 'WEST Bronze'
;
-- 24332 items 2013-08-22
-- 26606 items 2014-08-27
-- 26608 items 2015-07-31
-- 26637 items 2016-07-25
-- 26748 items 2017-07-10

-- (B) Shared Print Monographic series
with mfhds as (
  select distinct 
    record_id as mfhd_id
  from vger_subfields.ucladb_mfhd_subfield s
  where s.tag = '583f'
  and s.subfield like 'UCL Shared Print%'
  and exists (
    select *
    from vger_subfields.ucladb_mfhd_subfield
    where record_id = s.record_id
    and tag = '583f'
    and subfield like '%Monographic Series%'
  )
)
select 
  count(*) as num
from mfhds m
inner join ucladb.mfhd_master mm on m.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.mfhd_item mi on m.mfhd_id = mi.mfhd_id -- direct from m (small set)
inner join ucladb.item i on mi.item_id = i.item_id
inner join ucladb.item_type it on i.item_type_id = it.item_type_id
where l.location_code not like 'sr%'
and it.item_type_name = 'Shared Print in Place'
;
-- 43 items 2013-08-22
-- 70 items 2014-08-27
-- 100 items 2015-07-31
-- 131 items 2016-07-25
-- 168 items 2017-07-10
