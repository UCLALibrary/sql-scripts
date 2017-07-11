use Archivist_Toolkit;

with top_level as (
	select
		r.resourceid
	,	r.title as main_title
	,	rc.resourceComponentId
	,	rc.title as component_title
	,	rc.resourceLevel as rc1_resourceLevel
	from resources r
	inner join resourcescomponents rc on r.resourceid = rc.resourceid
	where r.resourceidentifier1 = 'LSC'
	and r.resourceidentifier2 = '1835'
)
-- LSC 1893 goes to rc3
-- Biomed 0402 goes to rc4
-- PASC-M 0137 goes to rc3
-- LSC 1835 goes to rc4 (only one row: series->file->file...)
, d as (
select 
	tl.*
--,	rc2.resourceComponentId as rc2_id
--,	rc2.resourceId -- null, only the parent->child resource component ids matter
,	rc2.title as rc2_title
,	rc2.dateExpression as rc2_dateExpression
,	rc2.resourceLevel as rc2_resourceLevel
,	rc2.sequenceNumber as rc2_sequenceNumber
-- ,	rc2.hasChild as rc2_hasChild -- seems to be unreliable... for example, resourceComponentId = 441339 has hasChild = 1 but no matching parentResourceComponentId  = 441339
--,	rc2.hasNotes as rc2_hasNotes
--,	rc2.persistentId as rc2_persistentId
-----
,	rc3.title as rc3_title
,	rc3.dateExpression as rc3_dateExpression
,	rc3.resourceLevel as rc3_resourceLevel
,	rc3.sequenceNumber as rc3_sequenceNumber
--,	rc3.hasNotes as rc3_hasNotes
--,	rc3.persistentId as rc3_persistentId
-----
,	rc4.title as rc4_title
,	rc4.dateExpression as rc4_dateExpression
,	rc4.resourceLevel as rc4_resourceLevel
,	rc4.sequenceNumber as rc4_sequenceNumber
--,	rc4.hasNotes as rc4_hasNotes
--,	rc4.persistentId as rc4_persistentId
from top_level tl -- 11 rows
inner join ResourcesComponents rc2 on tl.resourceComponentId = rc2.parentResourceComponentId
-- testing
-- 162 rows for LSC-1893 have rc3, all rc2.subseries -> rc3.file
-- 302 rows have NO rc3, all rc2.file
--   0 rows have rc4
left join ResourcesComponents rc3 on rc2.resourceComponentId = rc3.parentResourceComponentId
-- where rc3.resourceComponentId is null
left join ResourcesComponents rc4 on rc3.resourceComponentId = rc4.parentResourceComponentId
-- where rc4.resourceComponentId is not null
left join ResourcesComponents rc5 on rc4.resourceComponentId = rc5.parentResourceComponentId
--where rc4.resourceComponentId is not null
--order by cast(component_title as varchar), rc2.sequenceNumber, cast(rc2.title as varchar), rc3.sequenceNumber
)
select count(*) from d
;


select count(*) as num
from ResourcesComponents rc1
inner join ResourcesComponents rc2 on rc1.resourceComponentId = rc2.parentResourceComponentId
inner join ResourcesComponents rc3 on rc2.resourceComponentId = rc3.parentResourceComponentId
inner join ResourcesComponents rc4 on rc3.resourceComponentId = rc4.parentResourceComponentId
inner join ResourcesComponents rc5 on rc4.resourceComponentId = rc5.parentResourceComponentId
inner join ResourcesComponents rc6 on rc5.resourceComponentId = rc6.parentResourceComponentId
inner join ResourcesComponents rc7 on rc6.resourceComponentId = rc7.parentResourceComponentId
;
-- 1048759 in rc1 alone
--  825606 in rc1 ij rc2
--  397057 in rc1 ij rc2 ij rc3
--   57225 in rc1 ij rc2 ij rc3 ij rc4
--    6574 in rc1 ij rc2 ij rc3 ij rc4 ij rc5
--    1526 in rc1 ij rc2 ij rc3 ij rc4 ij rc5 ij rc6
--     398 in rc1 ij rc2 ij rc3 ij rc4 ij rc5 ij rc6 ij rc7



select count(*) as num
from Resources r
inner join ResourcesComponents rc1 on r.resourceId = rc1.resourceId
inner join ResourcesComponents rc2 on rc1.resourceComponentId = rc2.parentResourceComponentId
inner join ResourcesComponents rc3 on rc2.resourceComponentId = rc3.parentResourceComponentId
;
-- 223150 r->rc1
-- 426858 r->rc1->rc2
-- 339832 r->rc1->rc2->rc3

select 
	rc1.resourceLevel as rc1_resourceLevel
,	rc2.resourceLevel as rc2_resourceLevel
,	rc3.resourceLevel as rc3_resourceLevel
,	rc4.resourceLevel as rc4_resourceLevel
,	count(*) as num
from Resources r
inner join ResourcesComponents rc1 on r.resourceId = rc1.resourceId
left outer join ResourcesComponents rc2 on rc1.resourceComponentId = rc2.parentResourceComponentId
left outer join ResourcesComponents rc3 on rc2.resourceComponentId = rc3.parentResourceComponentId
left outer join ResourcesComponents rc4 on rc3.resourceComponentId = rc4.parentResourceComponentId
where r.resourceidentifier1 = 'PASC-M'
and r.resourceidentifier2 = '0137'
group by rc1.resourceLevel, rc2.resourceLevel, rc3.resourceLevel, rc4.resourceLevel
order by rc1.resourceLevel, rc2.resourceLevel, rc3.resourceLevel, rc4.resourceLevel
;
/*
 * 	LSC 1835
	recordgrp	series	file	
	recordgrp	series	file	file
	
	LSC 1893
	series	file	
	series	subseries	file	

	Biomed 0402
	series	file		
	series	series	subseries	file
	series	subseries	file	

	PASC-M 0137
	series	file	
	series	subseries	file
	series	subseries	item

 */



select *
from resources r
where r.resourceidentifier1 = 'LSC'
and r.resourceidentifier2 = '1893'
;


select *
from ArchDescriptionRepeatingData
where resourceid = 1295
and notesEtcTypeId = 26 -- Physical Characteristics and Technical Requirements NotesEtcTypes.notesEtcLabel
-- and notesEtcTypeId = 32 -- Separated Material NotesEtcTypes.notesEtcLabel
;

select * from dbo.NotesEtcTypes;
