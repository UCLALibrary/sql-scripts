/*  Inventory list for selected Clark locations.
    User wants selected subfields from several fields, formatted with subfields codes/delimiters.
    RR-334
    
    We would like to have the following fields:
        001 field from bib record
        852 field from holdings record
        100/110 field from bib record
        245 field from bib record
        260/264 field from bib record
        300 field from bib record
    Would it be possible to obtain subfields a,b, and c, for fields 100/110, 245, 260/264, and 300?
*/

select 
  bm.bib_id
, l.location_code
, ucladb.GetAllMFHDTag(mm.mfhd_id, '852', 2) as f852
-- Only existing way to get arbitrary subfields from arbitrary field, with delimiter info
-- bib_id, auth_id, mfhd_id - must specify all 3, with 0 for the 2 not relevant...
, vger_support.unifix(ucladb.GetMarcField(bm.bib_id, 0, 0, '100 110', '', 'abc')) as f1xx_abc
, vger_support.unifix(ucladb.GetMarcField(bm.bib_id, 0, 0, '245', '', 'abc')) as f245_abc
, vger_support.unifix(ucladb.GetMarcField(bm.bib_id, 0, 0, '260 264', '', 'abc')) as f26x_abc
, vger_support.unifix(ucladb.GetMarcField(bm.bib_id, 0, 0, '300', '', 'abc')) as f300_abc
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
where l.location_code in ('ckrf', 'ckrr', 'ckmt')
order by l.location_code, mm.normalized_call_no
;

