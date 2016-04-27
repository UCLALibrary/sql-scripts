/*  Extract requested data for list of ISBNs
    provided in Excel by Roxanne Peck.
    https://jira.library.ucla.edu/browse/RR-170

    Do all work as vger_report, for temporary working table/index.
    
    Create table and import data via JDeveloper.
    Needed to copy/paste column from Excel to text file before import -
    5819 rows too big for JDeveloper via Excel?  
    
    After import, create index
    create index ix_tmp_jstor_eisbn on tmp_jstor_eisbn (isbn);
*/

-- Only include matches
with isbns as (
select distinct
  j.isbn
, bi.normal_heading
, bi.bib_id
from tmp_jstor_eisbn j
inner join ucladb.bib_index bi
  on bi.index_code in ('020N', '020R', 'ISB3')
  and bi.normal_heading = j.isbn
)
select
  i.isbn
, i.bib_id
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = i.bib_id and tag = '264c' and rownum < 2) as f264c
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = i.bib_id and tag = '260c' and rownum < 2) as f260c
, l.location_code
, (select subfield from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852h' and rownum < 2) as f852h
from isbns i
inner join ucladb.bib_mfhd bm
  on i.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm
  on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l
  on mm.location_id = l.location_id
order by i.isbn, i.bib_id
;
-- 164 dups (82 source ISBN found in multiple bibs); example: 9780252095320
-- 5819 source rows; 1506 distinct isbns match voyager; 1588 rows in isbns (1506 + 82 dups); 1639 total rows; 1584 unique bibs, 49 bibs occur multiple times; example bib 7366061

-- Clean up when done
drop table tmp_jstor_eisbn purge;
