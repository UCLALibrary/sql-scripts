-- Run as vger_report
drop table vger_report.tmp_oclc_overlap purge;
create table vger_report.tmp_oclc_overlap (
  db char(1) not null
, bib_id int not null
, index_code char(4) not null
, oclc varchar2(10) not null
)
;
-- 2021-03-12:
--    13,725 E
--   167,146 F
-- 8,440,626 U

insert into vger_report.tmp_oclc_overlap (db, bib_id, index_code, oclc)
select distinct
  'F' as db -- CHANGE THIS
, bib_id
, index_code
, regexp_replace(normal_heading, '^0+', '') as oclc
--, normal_heading
--, display_heading
from filmntvdb.bib_index -- CHANGE THIS
where index_code in ('035A', '035Z')
-- Convert all-digit strings to null, everything else is not null - selects only all-digit strings
and replace(translate(normal_heading, '0123456789', '0000000000'), '0', '') is null
and display_heading like '(OCoLC)%'
;
commit;

create index vger_report.ix_tmp_oclc_overlap on vger_report.tmp_oclc_overlap (oclc, db);

-- Ethno / UCLA: 2218 matches
select 
  d1.oclc as src_oclc
, d1.db as src_db
, d1.index_code as src_index
, d1.bib_id as src_bib_id
, vger_support.unifix(bt1.author) as src_author
, vger_support.unifix(bt1.title_brief) as src_title_brief
, d2.db as tgt_db
, d2.index_code as tgt_index
, d2.bib_id as tgt_bib_id
, vger_support.unifix(bt2.author) as tgt_author
, vger_support.unifix(bt2.title_brief) as tgt_title_brief
from vger_report.tmp_oclc_overlap d1
inner join vger_report.tmp_oclc_overlap d2
  on d1.oclc = d2.oclc
  and d1.db = 'E'
  and d2.db = 'U'
inner join ethnodb.bib_text bt1 on d1.bib_id = bt1.bib_id
inner join ucladb.bib_text bt2 on d2.bib_id = bt2.bib_id
order by src_db, to_number(src_oclc), src_bib_id, tgt_bib_id
;


-- Ethno / FTVA: 0 matches
select 
  d1.oclc as src_oclc
, d1.db as src_db
, d1.index_code as src_index
, d1.bib_id as src_bib_id
, vger_support.unifix(bt1.author) as src_author
, vger_support.unifix(bt1.title_brief) as src_title_brief
, d2.db as tgt_db
, d2.index_code as tgt_index
, d2.bib_id as tgt_bib_id
, vger_support.unifix(bt2.author) as tgt_author
, vger_support.unifix(bt2.title_brief) as tgt_title_brief
from vger_report.tmp_oclc_overlap d1
inner join vger_report.tmp_oclc_overlap d2
  on d1.oclc = d2.oclc
  and d1.db = 'E'
  and d2.db = 'F'
inner join ethnodb.bib_text bt1 on d1.bib_id = bt1.bib_id
inner join filmntvdb.bib_text bt2 on d2.bib_id = bt2.bib_id
order by src_db, to_number(src_oclc), src_bib_id, tgt_bib_id
;


-- FTVA / UCLA: 3 matches
select 
  d1.oclc as src_oclc
, d1.db as src_db
, d1.index_code as src_index
, d1.bib_id as src_bib_id
, vger_support.unifix(bt1.author) as src_author
, vger_support.unifix(bt1.title_brief) as src_title_brief
, d2.db as tgt_db
, d2.index_code as tgt_index
, d2.bib_id as tgt_bib_id
, vger_support.unifix(bt2.author) as tgt_author
, vger_support.unifix(bt2.title_brief) as tgt_title_brief
from vger_report.tmp_oclc_overlap d1
inner join vger_report.tmp_oclc_overlap d2
  on d1.oclc = d2.oclc
  and d1.db = 'F'
  and d2.db = 'U'
inner join filmntvdb.bib_text bt1 on d1.bib_id = bt1.bib_id
inner join ucladb.bib_text bt2 on d2.bib_id = bt2.bib_id
order by src_db, to_number(src_oclc), src_bib_id, tgt_bib_id
;
