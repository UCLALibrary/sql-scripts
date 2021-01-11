/*  Collection Management activity report needed for Pandemic time period.
    Parts B and C from specs
    RR-597
*/
-- Part B: SCP records added since (and including) 3/20/2020
with d as (
  select
    bh.bib_id
    , case 
        when bt.bib_format in ('am') then 'Books'
        when bt.bib_format in ('ai', 'as') then 'Serials'
        when bt.bib_format in ('cm', 'cs') then 'Scores'
        when bt.bib_format in ('gm', 'gs', 'km', 'ks') then 'Videos/Visual materials'
        when bt.bib_format in ('im', 'is', 'jm', 'js') then 'Sound recordings'
        when bt.bib_format in ('mm', 'ms') then 'Computer Files'
        else 'UNKNOWN: ' || bt.bib_format
    end as format
  from bib_history bh
  inner join bib_text bt on bh.bib_id = bt.bib_id
  where bh.operator_id = 'scploader'
  and bh.action_type_id = 1 --create
  and bh.action_date >= to_date('20200320', 'YYYYMMDD')
)
select
  format
, count(*) as bibs
from d
group by rollup(format)
order by format
;
-- 91620 total

select * from bib_text where bib_format = '2s';

-- Part C: Shelf-ready records from various vendors, broken down by format
with bibs as (
  select bib_id
  from bib_history
  where operator_id = 'promptcat'
  and action_type_id = 1 --create
  and action_date >= to_date('20200320', 'YYYYMMDD')
)
, d as (
  select 
    b.bib_id
  , case 
      when lower(subfield) like 'bslw/lccoop%' then 'BSLW LC'
      when lower(subfield) like 'casalini%' then 'Casalini'
      when lower(subfield) like 'gobioclcplus%' then 'Gobi OCLC Plus'
      when lower(subfield) like 'marcnowhar%' then 'Harrassowitz'
      when lower(subfield) like 'promptcat%' then 'YBP Promptcat'
    end as vendor
  , case 
      when bt.bib_format in ('am') then 'Books'
      when bt.bib_format in ('ai', 'as') then 'Serials'
      when bt.bib_format in ('cm', 'cs') then 'Scores'
      when bt.bib_format in ('gm', 'gs', 'km', 'ks') then 'Videos/Visual materials'
      when bt.bib_format in ('im', 'is', 'jm', 'js') then 'Sound recordings'
      when bt.bib_format in ('mm', 'ms') then 'Computer Files'
      else 'UNKNOWN: ' || bt.bib_format
    end as format
  from bibs b
  inner join vger_subfields.ucladb_bib_subfield bs on b.bib_id = bs.record_id and bs.tag in ('910a', '910g', '920a')
  inner join bib_text bt on b.bib_id = bt.bib_id
  where lower(subfield) like 'bslw/lccoop%'
  or lower(subfield) like 'casalini%'
  or lower(subfield) like 'gobioclcplus%'
  or lower(subfield) like 'marcnowhar%'
  or lower(subfield) like 'promptcat%'
)
select 
  vendor
, format
, count(*) as bibs
from d
group by vendor, format
order by vendor, format
;
-- 1425

select subfield, count(*)
from vger_subfields.ucladb_bib_subfield
where tag = '910a'
and subfield like 'gobioclcplus 20%'
group by subfield
order by subfield desc
;

select *
from vger_subfields.ucladb_bib_subfield
where tag = '910a'
and subfield like 'gobioclcplus 200320'
order by record_id
