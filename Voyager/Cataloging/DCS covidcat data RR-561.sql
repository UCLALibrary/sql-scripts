/*  Data on COVID-related orders
    RR-561
*/
-- Basic bib and PO info from two sources
with cat as (
 -- Bibs with relevant 948 info and OPTIONAL POs 
 select
    bs.bib_id
  , bs.field_seq
  , 'CAT' as source
  , po.po_id
  -- Several 948-based criteria which can be most easily found here
  from vger_report.cat_948_base_rpt bs
  -- Must have internet holdings
  inner join bib_mfhd bm on bs.bib_id = bm.bib_id
  inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
  inner join location l on mm.location_id = l.location_id
  -- These bibs may not have POs
  left outer join line_item li on bs.bib_id = li.bib_id
  left outer join purchase_order po on li.po_id = po.po_id
  where bs.s948a like 'cmc%'
  and bs.s948c >= '20200501'
  and l.location_code = 'in' 
  -- Qualifying 948 field has a $d with just a single digit
  and exists (
    select *
    from vger_subfields.ucladb_bib_subfield
    where record_id = bs.bib_id
    and field_seq = bs.field_seq
    and tag = '948d'
    and regexp_like(subfield, '^[0-9]{1}$')
  )
)
, acq as (
  -- Bibs and MANDATORY POs ordered on/after 3/20/2020, any location/format/po type
  -- Distinct because some bibs are on multiple lines on a PO...
  select distinct
    li.bib_id
  , 'ACQ' as source
  , po.po_id
  from purchase_order po
  inner join line_item li on po.po_id = li.po_id
  -- PO header or line note must contain COVID (case-insensitive)
  inner join po_notes pon on po.po_id = pon.po_id
  inner join line_item_notes lin on li.line_item_id = lin.line_item_id
  where po.po_approve_date >= to_date('20200320', 'YYYYMMDD')
  and ( upper(pon.note) like '%COVID%' or upper(lin.note) like '%COVID%' )
)
, combined as (
  select bib_id, po_id from acq
  union-- de-dups, if any overlap
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
-- Getting loc from po-related holdings, which is null for CAT records - but those are all internet, per CAT query above
, case when l.location_code is null then 'in' else l.location_code end as location_code
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

