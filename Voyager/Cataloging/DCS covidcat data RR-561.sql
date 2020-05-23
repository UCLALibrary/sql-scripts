/*  Data on COVID-related orders
    RR-561
*/
select
  po.po_number
, po.po_approve_date as order_date
, pot.po_type_desc as po_type
, po.approve_opid as po_operator
, mh.operator_id as mfhd_operator
, v.vendor_code
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = li.bib_id and tag = '982b' and rownum < 2) as account
, (select replace(normal_heading, 'UCOCLC', '') from bib_index where bib_id = li.bib_id and index_code = '0350' and normal_heading like 'UCOCLC%' and rownum < 2) as oclc
, li.bib_id
, 'https://catalog.library.ucla.edu/vwebv/holdingsInfo?bibId=' || li.bib_id as permalink
, l.location_code
, substr(bt.bib_format, 2, 1) as bib_lvl
, substr(bt.bib_format, 1, 1) as rec_type
, bt.place_code
, bt.language
, bt.date_type_status as dt_st
, bt.begin_pub_date
, bt.end_pub_date
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.imprint) as imprint
, pon.note as po_note
, lin.note as line_note
from purchase_order po
inner join po_type pot on po.po_type = pot.po_type
inner join po_notes pon on po.po_id = pon.po_id -- verified no more than 1 note per PO
inner join vendor v on po.vendor_id = v.vendor_id 
inner join line_item li on po.po_id = li.po_id
inner join line_item_notes lin on li.line_item_id = lin.line_item_id -- verified no more than 1 note per line item
inner join line_item_copy_status lics on li.line_item_id = lics.line_item_id
inner join mfhd_master mm on lics.mfhd_id = mm.mfhd_id
inner join mfhd_history mh on mm.mfhd_id = mh.mfhd_id and mh.action_type_id = 1 -- Create
inner join location l on mm.location_id = l.location_id
inner join bib_text bt on li.bib_id = bt.bib_id
where po.normal_po_number like 'DCS%'
and po.po_approve_date >= to_date('20200320', 'YYYYMMDD')
and pot.po_type_desc != 'Continuation'
and po.po_number = 'DCS514160' -- TESTING
;
-- 100 PO as of 2020-05-21 14:01:11


-- Basic bib and PO info from two sources
with cat as (
 -- Bibs and OPTIONAL POs with 948 $k covidcat
 select
    bs.record_id as bib_id
  , 'CAT' as source
  , po.po_id
  from vger_subfields.ucladb_bib_subfield bs
  -- These bibs may not have POs
  left outer join line_item li on bs.record_id = li.bib_id
  left outer join purchase_order po on li.po_id = po.po_id
  where bs.tag = '948k'
  and bs.subfield like '%covidcat%' -- TESTING -- TODO: check exact value(s) once used
  --and bs.record_id between 7000000 and 7421600 -- TESTING with shpmono: gives 2 with POs, 3 without
)
, acq as (
  -- Bibs and MANDATORY POs ordered by DCS on/after 3/20/2020, not continuations
  -- DCS uses multiple line items for single bibs sometimes, like DCS513886 - maybe to add multiple line item notes?  DISTINCT doesn't help with this
  select 
    li.bib_id
  , 'ACQ' as source
  , po.po_id
  from purchase_order po
  inner join po_type pot on po.po_type = pot.po_type
  inner join line_item li on po.po_id = li.po_id
  where po.normal_po_number like 'DCS%'
  and po.po_approve_date >= to_date('20200320', 'YYYYMMDD')
  and pot.po_type_desc != 'Continuation'
  --and po.po_number = 'DCS514160' -- TESTING, has 30 line items
  --and po.normal_po_number = 'DCS513886' -- TESTING, has 6 line items (for 2 bibs...), and yes there's a space at the end of the PO number
)
, combined as (
  select bib_id, po_id from acq
  union -- de-dups, if any overlap
  select bib_id, po_id from cat
)
select
  po.po_number
, po.po_approve_date as order_date
, pot.po_type_desc as po_type
, po.approve_opid as po_operator
, mh.operator_id as mfhd_operator
, v.vendor_code
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and tag = '982b' and rownum < 2) as account
, pon.note as po_note
, lin.note as line_note
, (select replace(normal_heading, 'UCOCLC', '') from bib_index where bib_id = c.bib_id and index_code = '0350' and normal_heading like 'UCOCLC%' and rownum < 2) as oclc
, c.bib_id
, 'https://catalog.library.ucla.edu/vwebv/holdingsInfo?bibId=' || c.bib_id as permalink
, l.location_code
, substr(bt.bib_format, 2, 1) as bib_lvl
, substr(bt.bib_format, 1, 1) as rec_type
, bt.place_code
, bt.language
, bt.date_type_status as dt_st
, bt.begin_pub_date
, bt.end_pub_date
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, vger_support.unifix(bt.imprint) as imprint
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and tag = '300a' and rownum < 2) as phys_extent
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and tag = '856u' and rownum < 2) as url
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and tag = '948b' and rownum < 2) as cat_init
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and tag = '948c' and rownum < 2) as cat_date
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and tag = '948d' and rownum < 2) as cat_diff
-- All 948 $k.  That data is in AL16UTF16 - NVARCHAR which LISTAGG can't handle.  Convert to ASCII as we don't expect/care about Unicode in 948 $k.
, (select listagg(to_char(subfield), ', ') within group (order by field_seq, subfield_seq) from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and tag = '948k') as cat_proj 
from combined c
-- inner joins first, to get guaranteed bib info
inner join bib_text bt on c.bib_id = bt.bib_id
-- left outer joins last, to get optionsl (in some cases) acq info
left outer join purchase_order po on c.po_id = po.po_id
left outer join po_type pot on po.po_type = pot.po_type
left outer join po_notes pon on po.po_id = pon.po_id -- verified no more than 1 note per PO
left outer join vendor v on po.vendor_id = v.vendor_id 
left outer join line_item li on po.po_id = li.po_id and c.bib_id = li.bib_id -- only look for lines associated with the bibs we're focusing on
left outer join line_item_notes lin on li.line_item_id = lin.line_item_id -- verified no more than 1 note per line item
left outer join line_item_copy_status lics on li.line_item_id = lics.line_item_id
left outer join mfhd_master mm on lics.mfhd_id = mm.mfhd_id
left outer join mfhd_history mh on mm.mfhd_id = mh.mfhd_id and mh.action_type_id = 1 -- Create
left outer join location l on mm.location_id = l.location_id
order by po_number, bib_id
;
-- 1114 rows, representing 103 POs as of 2020-05-22 15:43:01


select * from vger_subfields.ucladb_bib_subfield where record_id = 9256853 and tag like '948%';

with d as (
select bib_id
, (select subfield from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and tag = '948k' and rownum < 2) as cat_diff
, (select listagg(to_char(subfield), ', ') within group (order by field_seq, subfield_seq) from vger_subfields.ucladb_bib_subfield where record_id = c.bib_id and tag = '948k') as cat_proj -- all 948 $k
from bib_text c
where bib_id = 9256853
)
select dump(cat_diff, 1016), dump(cat_proj, 1016) from d
/*
select dump(cat_diff, 1016), dump(cat_proj, 1016) from d
Typ=1 Len=18 CharacterSet=AL16UTF16: 0,47,0,43,0,56,0,52,0,4c,0,32,0,30,0,32,0,30	
Typ=1 Len=18 CharacterSet=US7ASCII: 0,47,0,43,0,56,0,52,0,4c,0,32,0,30,0,32,0,30
*/
;

