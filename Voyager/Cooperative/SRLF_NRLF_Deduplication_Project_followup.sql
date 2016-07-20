create table vger_report.tmp_rpt_rr160_ids (
  bib_id int not null
)
;
create index vger_report.ix_tmp_rpt_rr160_ids on vger_report.tmp_rpt_rr160_ids (bib_id);
-- import 214 ids via sqlldr

create table vger_report.tmp_srlf_rr160 as
select
  bt.bib_id
, bt.bib_format
, bt.field_008
, coalesce(bt.isbn, bt.issn) as isbn_or_issn
, ( select replace(normal_heading, 'UCOCLC', '')
    from ucladb.bib_index
    where bib_id = bt.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
    and rownum < 2
  ) as oclc
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.edition) as edition
, vger_support.unifix(bt.imprint) as imprint
, ( select subfield
    from vger_subfields.ucladb_bib_subfield
    where record_id = bt.bib_id
    and tag = '300a'
    and rownum < 2
  ) as f300a
, bt.language
, l.location_code
, l.location_name
, mi.mfhd_id
, mi.item_id
, ib.item_barcode
, mi.item_enum
, it.item_type_name
, mi.freetext
, istp.item_status_desc
, ist.item_status_date
from vger_report.tmp_rpt_rr160_ids ids
inner join ucladb.bib_text bt on ids.bib_id = bt.bib_id
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
inner join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join ucladb.location l on mm.location_id = l.location_id
inner join ucladb.mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join ucladb.item i on mi.item_id = i.item_id
inner join ucladb.item_type it on i.item_type_id = it.item_type_id
inner join ucladb.item_status ist on i.item_id = ist.item_id
inner join ucladb.item_status_type istp on ist.item_status = istp.item_status_type
inner join ucladb.item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 --Active
where (l.location_code in ('sr', 'srbuo') or l.location_code like 'srucl%')
;
-- 4944 rows
-- one bib from Excel list, 4661244 (IRE transactions on instrumentation) has no SRLF items...

-- Export data on server via sqlplus
set linesize 32767
set trimspool on
set trimout on

select
    bib_id || chr(9)
||  bib_format || chr(9)
||  field_008 || chr(9)
||  isbn_or_issn || chr(9)
||  oclc || chr(9)
||  author || chr(9)
||  title || chr(9)
||  edition || chr(9)
||  imprint || chr(9)
||  f300a || chr(9)
||  language || chr(9)
||  location_code || chr(9)
||  location_name || chr(9)
||  mfhd_id || chr(9)
||  item_id || chr(9)
||  item_barcode || chr(9)
||  item_enum || chr(9)
||  item_type_name || chr(9)
||  freetext || chr(9)
||  item_status_desc || chr(9)
||  item_status_date
from vger_report.tmp_srlf_rr160
order by bib_format, lpad(oclc, 9, '0'), bib_id, mfhd_id, item_enum
;

-- clean up
drop table vger_report.tmp_rpt_rr160_ids purge;
drop table vger_report.tmp_srlf_rr160 purge;