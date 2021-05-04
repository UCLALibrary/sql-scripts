/*  Bib and holdings data for "Rec Ser" UA records.
    RR-657
*/

select
  bm.bib_id
, bm.mfhd_id
, l.location_code
, l.location_name
, mm.display_call_no
, vger_support.get_oclc_number(bt.bib_id) as oclc
, substr(bt.bib_format, 1, 1) as rec_type
, substr(bt.bib_format, 2, 1) as bib_lvl
-- to_char because nvarchar2 subfield data gets borked by listagg
, ( select listagg(to_char(bs.subfield), ', ') within group (order by bs.subfield) --bs.field_seq, bs.subfield_seq)
    from vger_subfields.ucladb_bib_subfield bs
    where bs.record_id = bt.bib_id
    and bs.tag = '948c'
) as s948c
from mfhd_master mm
inner join location l on mm.location_id = l.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where mm.call_no_type = '8'
and upper(display_call_no) like '%REC%SER%'
order by l.location_code, mm.normalized_call_no
;
-- 530 bib/mfhds
