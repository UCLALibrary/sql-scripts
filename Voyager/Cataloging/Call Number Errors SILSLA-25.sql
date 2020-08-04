/*  Call Number Errors in Voyager Holdings Records
    SILSLA-25
    
    Needs to run at a quiet time when no changes are happening, and subfield db is up to date!
*/

with base as (
  select *
  from vger_subfields.ucladb_mfhd_subfield x
  where x.tag = '852b'
  and (subfield != 'in' and subfield not like 'sr%' and subfield not like '%acq%')
  and (
      exists (
        select * from vger_subfields.ucladb_mfhd_subfield
        where record_id = x.record_id
        and tag = '852h'
        and indicators like ' %'
      )
    or not exists (
      select * from vger_subfields.ucladb_mfhd_subfield
      where record_id = x.record_id
      and tag = '852h'
    )
  )
  and not exists (
    select * from vger_subfields.ucladb_mfhd_subfield
    where record_id = x.record_id
    and (tag like '852%' or tag like '866%')
    and ( upper(subfield) like '%IN PROCESS%' or upper(subfield) like '%SEE INDIVIDUAL%' or subfield like '%CSP%')
  )
)
--select count(*) from base; -- 135320
select
  bm.bib_id
, bm.mfhd_id
, l.location_code
, replace(b.indicators, ' ', '_') as ind
, vger_subfields.getfieldfromsubfields(b.record_id, b.field_seq, 'mfhd') as f852
from base b
inner join bib_mfhd bm on b.record_id = bm.mfhd_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
and mm.suppress_in_opac = 'N'
order by location_code, bib_id, mfhd_id
;

/*** VERSION 2 ***/
-- Start with a broad base set of holdings, then start removing
with base as (
  select
    x.record_id as mfhd_id
  from vger_subfields.ucladb_mfhd_subfield x
  where x.tag = '852b'
  and (subfield not in ('eainproc', 'in') and subfield not like 'sr%' and subfield not like '%acq%')
  and (
      exists (
        select * from vger_subfields.ucladb_mfhd_subfield
        where record_id = x.record_id
        and tag = '852h'
        and indicators like ' %'
      )
    or not exists (
      select * from vger_subfields.ucladb_mfhd_subfield
      where record_id = x.record_id
      and tag = '852h'
    )
  )
)
-- Suppressed records, explicit or via location
, suppressed_mfhds as (
  select
    mm.mfhd_id
  from mfhd_master mm
  inner join location l on mm.location_id = l.location_id
  where mm.suppress_in_opac = 'Y'
  or l.suppress_in_opac = 'Y'
)
-- Holdings records attached to suppressed bib records
, suppressed_bibs as (
  select
    bm.mfhd_id
  from bib_master b 
  inner join bib_mfhd bm on b.bib_id = bm.bib_id
  where b.suppress_in_opac = 'Y'
)
-- Holdings records with item/barcode status of In Process
, in_process as (
  select 
    mi.mfhd_id
  from mfhd_item mi
  inner join item_status ist on mi.item_id = ist.item_id
  inner join item_status_type istp on ist.item_status = istp.item_status_type
  where istp.item_status_desc = 'In Process'
)
-- Holdings records attached to p.o.s with status "Pending"  or "Canceled" or "Approved/Sent"
, has_po as (
  select
    lics.mfhd_id
  from purchase_order po
  inner join po_status pos on po.po_status = pos.po_status
  inner join line_item li on po.po_id = li.po_id
  inner join line_item_copy_status lics on li.line_item_id = lics.line_item_id
  where pos.po_status_desc in ('Pending', 'Canceled', 'Approved/Sent')
)
-- 852 or 866 field contains any of these text strings (see below or ticket)
, has_phrases as (
  select
    record_id as mfhd_id
  from vger_subfields.ucladb_mfhd_subfield
  where (tag like '852%' or tag like '866%')
  and (   upper(subfield) like '%IN PROCESS%'
      or  upper(subfield) like '%IN-PROCESS%'
      or  upper(subfield) like '%SEE INDIVIDUAL%' 
      or  subfield like '%CSP%'
      or  upper(subfield) like '%CAT-AS-SEP%'
      or  upper(subfield) like '%SEE INDIVIDUAL%'
      or  upper(subfield) like '%TO SRLF%'
      or  upper(subfield) like '%ON ORDER%'
  )
)
, filtered as (
  select mfhd_id from base
  minus
  select mfhd_id from suppressed_mfhds
  minus
  select mfhd_id from suppressed_bibs
  minus
  select mfhd_id from in_process
  minus
  select mfhd_id from has_po
  minus
  select mfhd_id from has_phrases
)
select
  bm.bib_id
, bm.mfhd_id
, ms.subfield as location_code
, replace(ms.indicators, ' ', '_') as ind
, vger_subfields.getfieldfromsubfields(ms.record_id, ms.field_seq, 'mfhd') as f852
from filtered f
inner join bib_mfhd bm on f.mfhd_id = bm.mfhd_id
inner join vger_subfields.ucladb_mfhd_subfield ms on f.mfhd_id = ms.record_id and ms.tag = '852b'
order by location_code, bib_id, mfhd_id
;

--select count(*) from filtered; 
-- 150871 in base
-- 49170 after removing suppressed mfhds
-- 44897 after removing suppressed bibs
-- 36802 after removing in process items
-- 33150 after removing holdings with the listed PO statuses
-- 21865 after removing 852/866 phrases
-- 21879 rows total

