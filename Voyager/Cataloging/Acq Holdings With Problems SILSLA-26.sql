/*  Voyager "acq" holdings records with unresolved issues
    SILSLA-26
*/

select 
  bm.bib_id
, bm.mfhd_id
, l.location_code
, vger_subfields.getfieldfromsubfields(ms.record_id, ms.field_seq, 'mfhd') as f852
from mfhd_master mm
inner join location l on mm.location_id = l.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join vger_subfields.ucladb_mfhd_subfield ms on mm.mfhd_id = ms.record_id and ms.tag = '852b'
where l.location_code like '%acq%'
and mm.create_date < to_date('20190101', 'YYYYMMDD')
order by location_code, bib_id, mfhd_id
;

