create table vger_report.tmp_gbs_import (
  bib_id int not null
, bib_level char(1)
, date_type char(1)
, date1 varchar2(4)
, date2 varchar2(4)
, pub_place varchar2(3)
, gov_doc char(1)
, gpo_item_no varchar2(100)
, sudoc_no varchar2(100)
, f099a varchar2(100)
, author nvarchar2(100) -- truncate these
, f245a nvarchar2(100) -- truncate these
, f245b nvarchar2(100) -- truncate these
, f26xa nvarchar2(100) -- truncate these
, f26xb nvarchar2(100) -- truncate these
, f26xc nvarchar2(100) -- truncate these
, loc_code varchar2(10)
, call_number varchar2(200)
, item_enum varchar2(100)
, item_barcode varchar2(20)
)
;
/*
  Imported all 559869 rows from UCLA 4/2018 list except for 1:
  Bib 6535150 has f245b longer than 2000 nchar which sqlldr can't handle, but
  it's for L0099884124 a biomed loc so no matter.
*/

create index vger_report.ix_tmp_gbs_import on vger_report.tmp_gbs_import (item_barcode);

select * from vger_report.tmp_gbs_import;

-- drop table vger_report.tmp_gbs_import purge;