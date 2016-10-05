/*  YBP PDA (patron-driven acquisitions) bib records which are 
    more than 2 years old and have never been ordered.
    Records are deleted via batchcat program.
    See https://jira.library.ucla.edu/browse/VBT-250
    
    Initial deletion: 2014-10-30: out of 37251 old PDA, 27737 will be deleted
    Program will run daily starting 2014-10-31.
    
    2016-10-05: Per https://jira.library.ucla.edu/browse/VBT-678
    no longer excluding Law records (916 $b LawDDA) from automatic deletion.
*/

with ybp_pda_bibs as (
  select record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '982a'
  and subfield = 'YBP'
)
select 
  y.bib_id
, mm.mfhd_id
from ybp_pda_bibs y
inner join ucladb.bib_master br on y.bib_id = br.bib_id
inner join ucladb.bib_mfhd bm on br.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where br.create_date < trunc(sysdate) - 730
and l.location_code = 'pdacq'
and not exists (
  select * from ucladb.line_item 
  where bib_id = y.bib_id
)
and not exists (
  select * from ucladb.line_item_copy_status
  where mfhd_id = mm.mfhd_id
)
order by y.bib_id, mm.mfhd_id
;
