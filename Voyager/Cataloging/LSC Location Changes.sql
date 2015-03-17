/*  Queries for many different sets of LSC records, for location changes.
    Data will be saved in separate text files and fed through LocationChanger.
    JIRA VBT-298.
    akohler March 2015.
*/

/*** Call number-based changes ***/

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' -- also do s
and mm.normalized_call_no like 'PS  374            D 5.9%' --PS374.D5.9
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 2405 m -> yrspboxm, 4 s -> yrspboxs


select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('DA530.9') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 650 m -> yrspboxm


select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('PZ2.5') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 3039 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('Z233.A96') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 1161 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('Z233.A76') || '%'
and mm.call_no_type = '0'
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'ASEI')
order by mm.mfhd_id
;
-- 948 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('HQ471.9') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 4933 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like 'Z 1033            P 3.9%' --Z1033.P3.9
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 971 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('Z233.B37') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 370 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('PQ9644.9') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 110 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('PZ2.4') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 4941 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('NC973.9') || '%'
and mm.call_no_type = '0'
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'GEC')
order by mm.mfhd_id
;
-- 1599 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('BF1272.9') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 1273 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('Z233.W35') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 304 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' --only
and mm.normalized_call_no like vger_support.NormalizeCallNumber('PQ6159.9') || '%'
and mm.call_no_type = '0'
order by mm.mfhd_id
;
-- 9502 m -> yrspboxm

/*** 852 $k-based changes ***/

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' -- also do s
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852k' and subfield = 'Sontag')
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'SON')
order by mm.mfhd_id
;
-- 15777 m -> yrspboxm, 642 s -> yrspboxs

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' -- only
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852k' and subfield = 'Schwartz')
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'LODS')
order by mm.mfhd_id
;
-- 895 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' -- only
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852k' and subfield = 'Montagu')
order by mm.mfhd_id
;
-- 2750 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' -- also do s
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '852k' and subfield = 'Haynes')
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'HAYN')
order by mm.mfhd_id
;
-- 8405 m -> yrspboxm, 947 s -> yrspboxs

/*** SPAC-based changes ***/

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' -- only
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'BRNH')
order by mm.mfhd_id
;
-- 675 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' -- only
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'RMNC')
order by mm.mfhd_id
;
-- 298 m -> yrspboxm

select 
  mm.mfhd_id
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
where l.location_code = 'yrspstax'
and bt.bib_format like '%m' -- only
and exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = mm.mfhd_id and tag = '901a' and subfield = 'BRG')
order by mm.mfhd_id
;
-- 1773 m -> yrspboxm


select * from mfhd_master where mfhd_id= 9275565;
select * from vger_subfields.ucladb_mfhd_subfield where tag = '852h' and subfield like 'Z1033.P3.9%' and rownum < 2;

select * from vger_subfields.ucladb_mfhd_subfield where tag = '852k' and subfield = 'Hollywood' and rownum < 2;
select count(*) from vger_subfields.ucladb_mfhd_subfield where tag = '852k' and subfield like 'Hollywood%';