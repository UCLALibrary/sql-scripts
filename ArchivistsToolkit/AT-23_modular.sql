use Archivist_Toolkit;

/*	
 * LSC 1835
--select * from level0 -- 1 row
--select * from level1 -- 21 rows
--select * from level2 -- 91 rows
--select * from level3 -- 8683 rows
--select * from level4 -- 1 row

LSC 1893
0	1
1	11
2	310	
3	162	
4	0
**/

-- create view AT23_Report as
alter view AT23_Report as
-- Top level resource data, with extra fields to allow unions with lower-level component data
with level0 as (
	select
		r.resourceId
	,	null	as resourceComponentId
	,	null	as parentResourceComponentId
	,	r.title
	,	r.dateExpression
	,	r.resourceLevel
	,	0	as sequenceNumber
	,	r.resourceidentifier1 + ' ' + r.resourceidentifier2 as refId
	,	0	as levelNumber
	from Resources r
	where r.resourceidentifier1 = 'LSC'
	and r.resourceidentifier2 = '0342' --'1893'--'0342'
)
,	level1 as (
	select
		rc1.resourceId
	,	rc1.resourceComponentId
	,	rc1.parentResourceComponentId
	,	rc1.title
	,	rc1.dateExpression
	,	rc1.resourceLevel
	,	rc1.sequenceNumber
	,	'' as refId
	,	1	as levelNumber
	from ResourcesComponents rc1
	-- level 1 components link to resources on resourceId, not (parent)resourceComponentId
	where rc1.resourceId in (select resourceId from level0)
)
,	level2 as (
	select
		rc2.resourceId
	,	rc2.resourceComponentId
	,	rc2.parentResourceComponentId
	,	rc2.title
	,	rc2.dateExpression
	,	rc2.resourceLevel
	,	rc2.sequenceNumber
	,	'' as refId
	,	2	as levelNumber
	from ResourcesComponents rc2
	-- level 2+ components link to parent components on (parent)resourceComponentId, not resourceId
	where rc2.parentResourceComponentId in (select resourceComponentId from level1)
)
,	level3 as (
	select
		rc3.resourceId
	,	rc3.resourceComponentId
	,	rc3.parentResourceComponentId
	,	rc3.title
	,	rc3.dateExpression
	,	rc3.resourceLevel
	,	rc3.sequenceNumber
	,	'' as refId
	,	3	as levelNumber
	from ResourcesComponents rc3
	-- level 2+ components link to parent components on (parent)resourceComponentId, not resourceId
	where rc3.parentResourceComponentId in (select resourceComponentId from level2)
)
,	level4 as (
	select
		rc4.resourceId
	,	rc4.resourceComponentId
	,	rc4.parentResourceComponentId
	,	rc4.title
	,	rc4.dateExpression
	,	rc4.resourceLevel
	,	rc4.sequenceNumber
	,	'' as refId
	,	4	as levelNumber
	from ResourcesComponents rc4
	-- level 2+ components link to parent components on (parent)resourceComponentId, not resourceId
	where rc4.parentResourceComponentId in (select resourceComponentId from level3)
)
,	all_data as (
	select * from level0
	union all
	select * from level1
	union all
	select * from level2
	union all
	select * from level3
	union all
	select * from level4
)
select * from all_data
;
-- End view definition

-- Queries for different resourceLevel (main, series, subseries, file)
-- which have different note / descriptor requirements.
-- Use the view, but be sure to alter the view definition for each collection identifier.

-- Main (resource) level
select 
	v.refId
,	v.title
,	nt.notesEtcLabel -- use the standard consistent label, not the resource-specific override
--,	n.title as noteTitle
,	replace(cast(n.noteContent as varchar(max)), char(10), '') as noteContent
from at23_report v
left outer join ArchDescriptionRepeatingData n -- notes
	on v.resourceId = n.resourceId -- top/main level only, uses resourceid and not resourceComponentId
left outer join NotesEtcTypes nt
	on n.notesEtcTypeId = nt.notesEtcTypeId
	--and nt.notesEtcLabel in ('Physical Characteristics and Technical Requirements', 'Separated Material')
where v.levelNumber = 0
--and nt.notesEtcLabel in ('Physical Characteristics and Technical Requirements', 'Separated Material')
order by v.levelNumber, v.sequenceNumber, cast(v.title as varchar)
;

-- Series (component) level
select
	v.title as seriesTitle
,	nt.notesEtcLabel -- use the standard consistent label, not the resource-specific override
--,	n.title as noteTitle
,	replace(cast(n.noteContent as varchar(max)), char(10), '') as noteContent
from at23_report v
left outer join ArchDescriptionRepeatingData n -- notes
	on v.resourceComponentId = n.resourceComponentId 
left outer join NotesEtcTypes nt
	on n.notesEtcTypeId = nt.notesEtcTypeId
	and nt.notesEtcLabel in ('Scope and Content', 'Physical Description', 'Physical Characteristics and Technical Requirements')
where v.resourceLevel = 'series'
--and nt.notesEtcLabel in ('Scope and Content', 'Physical Description', 'Physical Characteristics and Technical Requirements')
order by v.levelNumber, v.sequenceNumber, cast(v.title as varchar)
;

-- Sub-series (component) level
select
	v.title as subseriesTitle
,	nt.notesEtcLabel -- use the standard consistent label, not the resource-specific override
--,	n.title as noteTitle
,	replace(cast(n.noteContent as varchar(max)), char(10), '') as noteContent
from at23_report v
left outer join ArchDescriptionRepeatingData n -- notes
	on v.resourceComponentId = n.resourceComponentId 
left outer join NotesEtcTypes nt
	on n.notesEtcTypeId = nt.notesEtcTypeId
where v.resourceLevel = 'subseries'
and nt.notesEtcLabel in ('Scope and Content', 'Physical Description', 'Physical Characteristics and Technical Requirements')
order by v.levelNumber, v.sequenceNumber, cast(v.title as varchar)
;

-- File (component) level
-- Different data for files
select
	v.title as fileTitle
,	v.dateExpression
--,	adi.instanceType
,	case
		when adi.container1NumericIndicator is not null then coalesce(adi.container1Type, '') + ' ' + cast(adi.container1NumericIndicator as varchar(10))
		else ''
	end as instance_label_1
,	case
		when adi.container2NumericIndicator is not null then coalesce(adi.container2Type, '') + ' ' + cast(adi.container2NumericIndicator as varchar(10))
		else ''
	end as instance_label_2
,	case
		when adi.container3NumericIndicator is not null then coalesce(adi.container3Type, '') + ' ' + cast(adi.container3NumericIndicator as varchar(10))
		else ''
	end as instance_label_3
,	nt.notesEtcLabel -- use the standard consistent label, not the resource-specific override
--,	n.title as noteTitle
,	replace(cast(n.noteContent as varchar(max)), char(10), '') as noteContent
from at23_report v
inner join ArchDescriptionInstances adi on v.resourceComponentId = adi.resourceComponentId
left outer join ArchDescriptionRepeatingData n -- notes
	on v.resourceComponentId = n.resourceComponentId 
left outer join NotesEtcTypes nt
	on n.notesEtcTypeId = nt.notesEtcTypeId
where v.resourceLevel = 'file'
and nt.notesEtcLabel in ('Scope and Content', 'Physical Description', 'General note')
order by v.levelNumber, v.sequenceNumber, cast(v.title as varchar)
;


-- notes exploration

select * from NotesEtcTypes order by notesEtcLabel;

select 
	nt.notesEtcTypeId
,	nt.notesEtcName
,	nt.notesEtcLabel
,	n.title
,	count(*) as num
from ArchDescriptionRepeatingData n
inner join NotesEtcTypes nt on n.notesEtcTypeId = nt.notesEtcTypeId
--where nt.notesEtcTypeId = 26
group by nt.notesEtcTypeId,	nt.notesEtcName,	nt.notesEtcLabel,	n.title
order by 1
;

-- some resources have multiple notes of the type we want
select
	r.resourceid
,	count(*) as num
from resources r
inner join ArchDescriptionRepeatingData n
	on r.resourceid = n.resourceid
where n.notesEtcTypeId = 26
group by r.resourceid
having count(*) > 1
;

-- revised file list
select 
	s.title as series_title
,	s.resourcelevel
,	v.title as file_title
,	v.dateExpression
,	case
		when adi.container1NumericIndicator is not null then coalesce(adi.container1Type, '') + ' ' + cast(adi.container1NumericIndicator as varchar(10))
		else ''
	end as instance_label_1
,	case
		when adi.container2NumericIndicator is not null then coalesce(adi.container2Type, '') + ' ' + cast(adi.container2NumericIndicator as varchar(10))
		else ''
	end as instance_label_2
,	case
		when adi.container3NumericIndicator is not null then coalesce(adi.container3Type, '') + ' ' + cast(adi.container3NumericIndicator as varchar(10))
		else ''
	end as instance_label_3
,	nt.notesEtcLabel -- use the standard consistent label, not the resource-specific override
--,	n.title as noteTitle
,	replace(cast(n.noteContent as varchar(max)), char(10), '') as noteContent
from at23_report v
-- include some parent info for files
inner join at23_report s on v.parentResourceComponentId = s.resourceComponentId
inner join ArchDescriptionInstances adi on v.resourceComponentId = adi.resourceComponentId
left outer join ArchDescriptionRepeatingData n -- notes
	on v.resourceComponentId = n.resourceComponentId 
left outer join NotesEtcTypes nt
	on n.notesEtcTypeId = nt.notesEtcTypeId
where v.resourceLevel = 'file'
--and v.parentResourceComponentId = 395215
--and nt.notesEtcLabel in ('Scope and Content', 'Physical Description', 'General note')
order by s.levelNumber, s.sequenceNumber, cast(s.title as varchar), v.sequenceNumber, cast(v.title as varchar)
;

select * from resourcescomponents where resourcecomponentid = 395215;
select * from dbo.ResourcesComponents where parentResourceComponentId = 395215 order by cast(title as varchar);
select * from resourcescomponents where persistentid = 'ref352' and cast(title as varchar) = 'Film';

select * from resourcescomponents where persistentid = 'ref352' and resourceid != 1220; -- 122 rows
select * from resourcescomponents where persistentid != 'ref352' and resourceid = 1220; -- 38 rows



select * from at23_report where cast(title as varchar) like '%Crawford%';


select
	r.resourceId
,	r.title as collection_title
,	r.dateExpression
,	r.resourceLevel
,	r.resourceidentifier1 + ' ' + r.resourceidentifier2 as collection_number
,	rc.resourceComponentId
,	rc.resourceLevel
,	rc.sequenceNumber
,	rc.hasChild
,	rc.title
from dbo.Resources r
inner join dbo.ResourcesComponents rc on r.resourceId = rc.resourceId
where r.resourceidentifier1 = 'LSC'
and r.resourceidentifier2 = '0342'
order by rc.sequenceNumber 
;












/*Synanon LSC 0342
LSC 1179 richard and dion neutra papers
*/