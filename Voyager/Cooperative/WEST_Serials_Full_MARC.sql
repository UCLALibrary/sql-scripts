/*  WEST wants serials (format 'as'), with CLU/ZAS holdings separate.
    Exclude gov docs (008/28 must be blank)
    ZAS = sr, srucl%
    CLU = everything else
    2011-10-18 akohler
    
*/
create table vger_report.tmp_west_serials as
with west_mfhds as (
  select record_id as mfhd_id
  from vger_subfields.ucladb_mfhd_subfield
  where tag = '583f'
  and subfield = 'WEST'
)
, west_bibs as (
  select bib_id
  from ucladb.bib_mfhd
  where mfhd_id in (
    select mfhd_id from west_mfhds
  )
)
select
  bm.bib_id
, bm.mfhd_id
, l.location_code
from ucladb.bib_text bt
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.bib_master br on bt.bib_id = br.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
where bt.bib_format = 'as'
and substr(bt.field_008, 29, 1) = ' '
and br.suppress_in_opac = 'N'
and mm.suppress_in_opac = 'N'
and l.suppress_in_opac = 'N'
and not exists (
  select *
  from west_bibs
  where bib_id = bm.bib_id
)
;
create index vger_report.ix_tmp_west_loc on vger_report.tmp_west_serials (location_code);

select count(*) as al, count(distinct bib_id) as b, count(distinct mfhd_id) as m from tmp_west_serials;

-- CLU bibs
select count(distinct bib_id)
from vger_report.tmp_west_serials
where location_code not in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4')
;
--111570

-- ZAS bibs
select count(distinct bib_id)
from vger_report.tmp_west_serials
where location_code in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4')
;
--73603

-- CLU hols
select count(distinct mfhd_id)
from vger_report.tmp_west_serials
where location_code not in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4')
;
--136199

-- ZAS hols
select count(distinct mfhd_id)
from vger_report.tmp_west_serials
where location_code in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4')
;
--76811

-- Data for CLU spreadsheet
select
  location_code
, 'CLU' as oclc_symbol
, '852 $b' as subfield
, '' as storage -- use Y for ZAS, blank for CLU
from ucladb.location
where location_code in (
  select distinct location_code
  from vger_report.tmp_west_serials
  where location_code not in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4')
)
order by location_code
;

-- Data for ZAS spreadsheet
select
  location_code
, 'ZAS' as oclc_symbol
, '852 $b' as subfield
, 'Y' as storage -- use Y for ZAS, otherwise blank
from ucladb.location
where location_code in (
  select distinct location_code
  from vger_report.tmp_west_serials
  where location_code in ('sr', 'srucl', 'srucl2', 'srucl3', 'srucl4')
)
order by location_code
;

/**********
  Extract the bib and holdings records using shell script /m1/voyager/ucladb/local/west/annual_extract/extract_west
**********/

drop table vger_report.tmp_west_serials purge;


  