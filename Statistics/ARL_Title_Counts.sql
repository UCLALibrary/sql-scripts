/*  1.  Voyager – Count all bibliographic records created before end of FY where:  
        a. Bib record lacks OCLC#
        b. Bib record is not suppressed, and
        c. At least one unsuppressed holdings record with either no acq status (no PO)
           or acq status “received” is associated with the bib record, 
           and has a code other than one of the following in the 852 $b:
          i.  patron driven acq (‘pdacq’)
          ii. all the personal reserves locations ('%rsprscp')

    2.  Voyager Serials in Online Format
        Count unsuppressed serial bibliographic records that have unsuppressed Internet holdings 
        in addition to unsuppressed print holdings

    3. Voyager Serials in Microform
       Count unsuppressed serial bibliographic records that have unsuppressed microform holdings 
       in addition to unsuppressed print holdings

    For each report, need to run both GROUPED by unit for unit-level list, and with COUNT DISTINCT (bib_id) ungrouped for summary counts.
    These counts won't match because some bibs have multiple qualifying holdings units (more bib/unit than bib).
    Comment in/out the l.unit and group by l.unit lines.
    
    20130716: per John Riemer, no need for breakdown by unit, just total across entire collection (including Internet & SRLF)

*/

define CREATED_BEFORE = '2014-07-01';

-- Report 1: No OCLC... somethings
-- Really slow with location info; create temp table
create table vger_report.tmp_no_oclc as
  select bm.bib_id
  from ucladb.bib_master bm
  where bm.suppress_in_opac = 'N'
  and bm.create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')
  -- No OCLC number
  and not exists (
    select *
    from ucladb.bib_index
    where bib_id = bm.bib_id
    and index_code = '0350'
    and normal_heading like 'UCOCLC%'
  )
;
create index vger_report.ix_tmp_no_oclc on vger_report.tmp_no_oclc (bib_id);

select 
  count(distinct bm.bib_id) as bibs
-- , l.unit
from vger_report.tmp_no_oclc bm
inner join ucladb.bib_mfhd bmd on bm.bib_id = bmd.bib_id
inner join ucladb.mfhd_master mm on bmd.mfhd_id = mm.mfhd_id
-- inner join vger_support.locations_by_unit l on mm.location_id = l.location_id
inner join ucladb.location l on mm.location_id = l.location_id
where mm.suppress_in_opac = 'N'
and l.suppress_in_opac = 'N'
-- and (l.stats = 'Y' or l.location_code = 'in') -- testing: Internet, SRLF and ISSR are not stats units
and l.location_code != 'pdacq' -- patron driven acq
and l.location_code not like '%rsprscp' -- personal reserves
-- No PO line item, or has "received" acq status
and (
      not exists (
        select *
        from ucladb.line_item_copy_status
        where mfhd_id = mm.mfhd_id
      )
  or
      exists (
        select *
        from ucladb.line_item_copy_status
        where mfhd_id = mm.mfhd_id
        and line_item_status = 1 -- Received Complete
      )
)
-- group by l.unit
-- order by l.unit
;
drop table vger_report.tmp_no_oclc purge;

-- Report 2: Internet serials with print
select 
  count(distinct bt.bib_id) as bibs
--, l.unit
from ucladb.bib_text bt
inner join ucladb.bib_master bm on bt.bib_id = bm.bib_id
inner join ucladb.bib_mfhd bmd on bm.bib_id = bmd.bib_id
inner join ucladb.mfhd_master mm on bmd.mfhd_id = mm.mfhd_id
-- inner join vger_support.locations_by_unit l on mm.location_id = l.location_id
inner join ucladb.location l on mm.location_id = l.location_id
where bt.bib_format = 'as'
and bm.suppress_in_opac = 'N'
and mm.suppress_in_opac = 'N'
and l.suppress_in_opac = 'N'
-- and l.stats = 'Y'
and bm.create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')
-- "Print" holding = not internet
and l.location_code != 'in'
-- But also has internet
and exists (
  select *
  from ucladb.bib_mfhd bmd2
  inner join ucladb.mfhd_master mm2 on bmd2.mfhd_id = mm2.mfhd_id
  inner join ucladb.location l2 on mm2.location_id = l2.location_id
  where bmd2.bib_id = bmd.bib_id
  and bmd2.mfhd_id != bmd.mfhd_id
  and l2.location_code = 'in'
  and mm2.suppress_in_opac = 'N'
)
-- group by l.unit
-- order by l.unit
;


-- Report 3: Microform serials with print
select 
  count(distinct bt.bib_id) as bibs
-- , l.unit
from ucladb.bib_text bt
inner join ucladb.bib_master bm on bt.bib_id = bm.bib_id
inner join ucladb.bib_mfhd bmd on bm.bib_id = bmd.bib_id
inner join ucladb.mfhd_master mm on bmd.mfhd_id = mm.mfhd_id
-- inner join vger_support.locations_by_unit l on mm.location_id = l.location_id
inner join ucladb.location l on mm.location_id = l.location_id
where bt.bib_format = 'as'
and bm.suppress_in_opac = 'N'
and mm.suppress_in_opac = 'N'
and l.suppress_in_opac = 'N'
-- and l.stats = 'Y'
and bm.create_date < to_date('&CREATED_BEFORE', 'YYYY-MM-DD')
-- "Print" holding = not internet
and l.location_code != 'in'
-- But also has microform
and exists (
  select *
  from ucladb.bib_mfhd bmd2
  inner join ucladb.mfhd_master mm2 on bmd2.mfhd_id = mm2.mfhd_id
  inner join ucladb.location l2 on mm2.location_id = l2.location_id
  where bmd2.bib_id = bmd.bib_id
  and bmd2.mfhd_id != bmd.mfhd_id
  and l2.location_code in (
    select location_code 
    from ucladb.location 
    where upper(location_display_name) like '%MICROF%'
    or upper(location_name) like '%MICR%'
    or location_code like 'yrmi%'
  )
  and mm2.suppress_in_opac = 'N'
)
-- group by l.unit
-- order by l.unit
;

