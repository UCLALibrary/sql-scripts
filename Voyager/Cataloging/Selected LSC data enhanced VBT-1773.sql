--drop table vger_report.tmp_vbt_1773 purge;
create index vger_report.ix_tmp_vbt_1773 on vger_report.tmp_vbt_1773 (bib_id);
-- 953 rows imported 

select 
  t.id
, t.bib_id
, substr(bt.bib_format, 1, 1) as rec_type
, substr(bt.bib_format, 2, 1) as bib_lvl
, ucladb.getbibtag(t.bib_id, '006') as f006
, ucladb.getbibtag(t.bib_id, '007') as f007
, t.type_lib
, t.f700
from vger_report.tmp_vbt_1773 t
inner join ucladb.bib_text bt on t.bib_id = bt.bib_id
order by id
;

select min(record_id) from vger_subfields.ucladb_bib_subfield bs where tag = '006' and exists (select * from vger_subfields.ucladb_bib_subfield where record_id = bs.record_id and tag = '007');

select ucladb.getbibtag(bib_id, '006') from ucladb.bib_text where bib_id = 4803;
select * from vger_subfields.ucladb_bib_subfield where record_id = 511 and tag = '007';

select * from vger_subfields.ucladb_bib_subfield bs where tag = '006' and exists (select * from vger_subfields.ucladb_bib_subfield where record_id = bs.record_id and tag = bs.tag and field_seq != bs.field_seq);