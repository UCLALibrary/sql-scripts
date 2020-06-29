/*  digital2 URLs in Voyager records
    VBT-1628
*/

-- Bibs
select 
  bs.record_id as bib_id
, vger_support.unifix(bt.title_brief) as title_brief
, subfield as url
, vger_subfields.getfieldfromsubfields(bs.record_id, bs.field_seq) as f856
from vger_subfields.ucladb_bib_subfield bs
inner join bib_text bt on bs.record_id = bt.bib_id
where bs.tag = '856u'
and bs.subfield like '%digital2.library.ucla.edu%'
order by bs.record_id, bs.field_seq
;
--106 (102)

-- Bibs
select 
  bt.bib_id
, vger_support.unifix(bt.title_brief) as title_brief
, subfield as url
, vger_subfields.getfieldfromsubfields(ms.record_id, ms.field_seq, 'mfhd') as f856
from vger_subfields.ucladb_mfhd_subfield ms
inner join bib_mfhd bm on ms.record_id = bm.mfhd_id
inner join bib_text bt on bm.mfhd_id = bt.bib_id
where ms.tag = '856u'
and ms.subfield like '%digital2.library.ucla.edu%'
order by bt.bib_id, ms.field_seq
;


