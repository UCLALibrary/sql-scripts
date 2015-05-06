/*  Match OCLC numbers for Hebraica records to Voyager.
    Data provided by Dawn Aveline.
    JIRA VBT-391.
    akohler 2015-05-05
*/

-- Temporary table for imported data
create table vger_report.tmp_oclc_import (
  oclc_number varchar2(20) not null
)
;
-- imported from hebraica.tsv

select * from vger_report.tmp_oclc_import group by oclc_number having count(*) > 1;

update vger_report.tmp_oclc_import set oclc_number = 'UCOCLC' || oclc_number;
commit;

create index vger_report.tmp_oclc_import_ix on vger_report.tmp_oclc_import (oclc_number);
select * from vger_report.tmp_oclc_import order by length(oclc_number) desc;

-- imported table has duplicate oclc numbers
select distinct
  replace(o.oclc_number, 'UCOCLC', '') as oclc_number
, bm.bib_id
, bm.mfhd_id
, l.location_code
, ib.item_barcode
, mi.item_enum
, ( select subfield 
    from vger_subfields.ucladb_bib_subfield
    where record_id = bm.bib_id
    and tag = '948k'
    and upper(subfield) = 'YRLBLEVEL'
    and rownum < 2
  ) as s948k
, vger_support.unifix(bt.title) as title
from vger_report.tmp_oclc_import o
left outer join ucladb.bib_index bi
  on bi.index_code = '0350'
  and o.oclc_number = bi.normal_heading
left outer join ucladb.bib_text bt on bi.bib_id = bt.bib_id
left outer join ucladb.bib_mfhd bm on bi.bib_id = bm.bib_id
left outer join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
left outer join ucladb.location l on mm.location_id = l.location_id
left outer join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join ucladb.item_barcode ib on mi.item_id = ib.item_id
where (ib.barcode_status is null or ib.barcode_status = 1) --Active
and bm.bib_id is null
order by oclc_number, bm.bib_id, bm.mfhd_id, mi.item_enum
;

-- Clean up
drop table vger_report.tmp_oclc_import purge;

select count(distinct oclc_number) from vger_report.tmp_oclc_import;