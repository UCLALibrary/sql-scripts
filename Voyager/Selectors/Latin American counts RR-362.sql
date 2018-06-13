/*  Latin American (and beyond) publications.
    RR-362
*/
-- Selected countries, divided by region for separate reporting
select 
  place_code
, count(distinct bt.bib_id) as bibs
, count(*) as items
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
-- Not all holdings have items
left outer join mfhd_item mi on bm.mfhd_id = mi.mfhd_id
--where bt.place_code in ('mx')
--where bt.place_code in ('cr', 'es', 'gt', 'ho', 'nq', 'pn')
where bt.place_code in ('ag', 'bl', 'bh', 'bo', 'ck', 'cl', 'ec', 'pe', 'py', 'uy', 've')
--where bt.place_code in ('cu', 'dr', 'pr')
group by bt.place_code
order by place_code
;


-- Selected 043 $a values, where place_code is not in the lists above.
with bibs as (
  select distinct record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '043a'
  and subfield in (
  	'n-mx---', 'nccr---', 'nces---', 'ncgt---', 'ncho---', 'ncnq---', 'ncpn---', 'nccz---', 's-ag---', 's-bo---'
	, 's-bl---', 's-cl---', 's-ck---', 's-ec---', 's-py---', 's-pe---', 's-uy---', 's-ve---', 'nwcu---', 'nwdr---'
	, 'nwhi---', 'mwpr---', 'sa-----', 'sn-----', 'sp-----', 'ncbh---'
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
  'mx', 'cr', 'es', 'gt', 'ho', 'nq', 'pn', 'ag', 'bl', 'bo', 'ck', 'cl', 'ec', 'pe', 'py', 'uy', 've', 'cu', 'dr', 'pr', 'bh'
)
;
-- Not considering Belize: 41485	64775
-- Considering Belize: 41727	65129
