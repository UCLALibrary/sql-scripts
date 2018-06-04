/*  Middle Eastern (and beyond) publications.
    RR-360
*/
-- Selected African countries
select 
  place_code
, count(distinct bt.bib_id) as bibs
, count(*) as items
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
-- Not all holdings have items
left outer join mfhd_item mi on bm.mfhd_id = mi.mfhd_id
where bt.place_code in ('ae', 'eg', 'ly', 'mr', 'ti', 'ss')
group by bt.place_code
order by place_code
;

-- Selected Asian countries
select 
  place_code
, count(distinct bt.bib_id) as bibs
, count(*) as items
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
-- Not all holdings have items
left outer join mfhd_item mi on bm.mfhd_id = mi.mfhd_id
where bt.place_code in (
  'af', 'ai', 'aj', 'ba', 'cy', 'gz', 'gs', 'ir', 'iq', 'iy'
, 'is', 'jo', 'kz', 'ku', 'kg', 'le', 'mp', 'mk', 'qa', 'su'
, 'sy', 'ta', 'tu', 'tk', 'ts', 'uz', 'wj', 'ye'
)
group by bt.place_code
order by place_code
;

-- Selected 043 $a values, where place_code is not in the lists above.
with bibs as (
  select distinct record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '043a'
  and subfield in (
      'f-ae---', 'f-ua---', 'f-ly---', 'f-mr---', 'f-ti---', 'f-ss---', 'fa-----', 'ff-----', 'fh-----', 'fu-----'
    , 'ma-----', 'a-af---', 'a-ai---', 'a-aj---', 'a-ba---', 'a-cy---', 'a-gs---', 'a-ir---', 'a-iq---', 'a-is---'
    , 'a-jo---', 'a-kz---', 'a-ku---', 'a-kg---', 'a-le---', 'a-mp---', 'a-mk---', 'a-qa---', 'a-su---', 'a-sy---'
    , 'a-ta---', 'a-tu---', 'a-tk---', 'a-ts---', 'a-uz---', 'a-ye---', 'ac-----', 'ak-----', 'ap-----', 'ar-----'
    , 'au-----', 'aw-----', 'awba---', 'awgz---', 'e-urk--', 'e-urw--'
  )
)
select
  count(distinct b.bib_id) as bibs
, count(*) as items
from bibs b
inner join bib_text bt on b.bib_id = bt.bib_id
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
-- Not all holdings have items
left outer join mfhd_item mi on bm.mfhd_id = mi.mfhd_id
where bt.place_code not in (
  'af', 'ai', 'aj', 'ba', 'cy', 'gz', 'gs', 'ir', 'iq', 'iy'
, 'is', 'jo', 'kz', 'ku', 'kg', 'le', 'mp', 'mk', 'qa', 'su'
, 'sy', 'ta', 'tu', 'tk', 'ts', 'uz', 'wj', 'ye'
)
;
