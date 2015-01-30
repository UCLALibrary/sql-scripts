/*  Extract Voyager data for SRLF/NRLF de-duplication project
    Specs: https://jira.library.ucla.edu/browse/RR-44
    2014-11-26 akohler
*/

select
  bt.bib_id
, bt.bib_format
, coalesce(bt.isbn, bt.issn) as isbn_or_issn
, ( select replace(normal_heading, 'UCOCLC', '') 
    from bib_index
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
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
inner join item i on mi.item_id = i.item_id
inner join item_type it on i.item_type_id = it.item_type_id
inner join item_status ist on i.item_id = ist.item_id
inner join item_status_type istp on ist.item_status = istp.item_status_type
inner join item_barcode ib on i.item_id = ib.item_id and ib.barcode_status = 1 --Active
where (l.location_code in ('sr', 'srbuo') or l.location_code like 'srucl%')
order by bib_format, lpad(oclc, 9, '0'), bib_id, mfhd_id, item_enum
;

-- 2014-12-19: UCB realised they also need to konw if gov document, so requested
-- bib id and bib 008 as separate file.
-- Only need bib data, but must use loc and existence of items.
select distinct
  bt.bib_id
, bt.field_008
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join mfhd_item mi on mm.mfhd_id = mi.mfhd_id
where (l.location_code in ('sr', 'srbuo') or l.location_code like 'srucl%')
;