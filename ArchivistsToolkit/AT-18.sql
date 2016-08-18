/*	Archivists' Toolkit reports on specific finding aid
 *	for Yasmin Dessem
 *	https://jira.library.ucla.edu/browse/AT-18
 */
use Archivist_Toolkit;

with top_level as (
	select
		r.resourceid
	,	r.title as main_title
	,	rc.resourceComponentId
	,	rc.title as component_title
	from resources r
	inner join resourcescomponents rc on r.resourceid = rc.resourceid
	where r.resourceidentifier1 = 'PASC-M'
	and r.resourceidentifier2 = '0072'
)
select 
	tl.resourceid
,	tl.resourceComponentId as parent_id
,	rc2.resourceComponentId as component_id
,	rc3.resourceComponentId as file_id
,	tl.main_title
,	tl.component_title
,	rc2.title as subseries_title
,	rc2.subdivisionIdentifier as component_unique_id
--,	rc2.persistentId
--,	rc2.resourcelevel
,	rc2.extentNumber
,	rc2.extentType
,	rc3.title as file_title
,	adi.instanceType
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
,	notes.noteContent
from top_level tl
inner join ResourcesComponents rc2 on tl.resourceComponentId = rc2.parentResourceComponentId
inner join ResourcesComponents rc3 on rc2.resourceComponentId = rc3.parentResourceComponentId
inner join ArchDescriptionInstances adi on rc3.resourceComponentId = adi.resourceComponentId
left outer join ArchDescriptionRepeatingData notes 
	on rc3.resourceComponentId = notes.resourceComponentId
	and notes.notesEtcTypeId = 16 -- physical description
where rc2.resourceLevel = 'subseries'
and rc3.resourceLevel = 'file'
-- testing
--and rc2.resourceComponentId = 463668
order by cast(component_title as varchar), rc2.sequenceNumber, cast(rc2.title as varchar), rc3.sequenceNumber
;
