/*  List arbt holdings with no items, for suppression.
    * Do not suppress holdings records with items attached
    * Do not suppress holdings with call numbers including "v." or "no." 
    
    e.g., suppress holdings with no items, where the call number doesn't have "v." or "no.".
    VBT-1117
*/

-- Will suppress 338 holdings, out of 734 total - suppression done via GDC
-- Another 224 holdings suppressed which have no call no. at all (and no items).
select
  l.location_code
, mm.mfhd_id
, mi.item_id
, mm.display_call_no
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
where l.location_code in ('arbt', 'arbt*', 'arbt**&***')
and mm.suppress_in_opac = 'N'
and mi.item_id is null
and (   ( mm.display_call_no not like '%no.%'
      and mm.display_call_no not like '%v.%'
      )
    or    mm.display_call_no is null
)  
order by mm.mfhd_id
;

-- After suppression, report on what in these locations is not suppressed
select
  l.location_code
, bt.bib_id
, ib.item_barcode
, mm.display_call_no
, mi.item_enum
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
left outer join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
left outer join item_barcode ib on mi.item_id = ib.item_id and ib.barcode_status = 1 --Active
where l.location_code in ('arbt', 'arbt*', 'arbt**&***')
and mm.suppress_in_opac = 'N'
order by location_code, bib_id, item_enum
;
-- 39 with no items; 187 total