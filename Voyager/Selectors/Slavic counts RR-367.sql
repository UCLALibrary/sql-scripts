/*  Slavic (and beyond) publications.
    RR-367
*/
-- Selected countries
select 
  place_code
, count(distinct bt.bib_id) as bibs
, count(*) as items
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
-- Not all holdings have items
left outer join mfhd_item mi on bm.mfhd_id = mi.mfhd_id
where bt.place_code in ('ru', 'pl', 'bn', 'ci', 'rb')
group by bt.place_code
order by place_code
;


-- Selected 043 $a values, where place_code is not in the lists above.
with bibs as (
  select distinct record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '043a'
  and subfield in (
    	'e-ru---', 'e-pl---', 'e-bn---', 'e-ci---', 'e-rb---', 'e-urc--', 'e-ure--', 'e-urf--', 'e-urk--', 'e-urn--'
    ,	'e-urp--', 'e-urr--', 'e-urs--', 'e-uru--', 'e-urw--', 'e-yu---', 'ed-----'
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
  'ru', 'pl', 'bn', 'ci', 'rb'
)
;
-- 22896	38476

-- For this one, they also want languages
select 
  language
, count(distinct bt.bib_id) as bibs
, count(*) as items
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
-- Not all holdings have items
left outer join mfhd_item mi on bm.mfhd_id = mi.mfhd_id
where bt.language in ('bos', 'hrv', 'pol', 'rus', 'srp')
group by bt.language
order by language
;

