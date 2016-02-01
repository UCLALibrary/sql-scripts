select 
	s.SessionDateTime,
	atl.ActivityType as SessionType,
	a.Title,
	dbo.build_sess_dept_title(s.SessionID) as Departments,
	s.CourseNumber,
	s.CourseSection,
	s.GroupName,
	dbo.build_learner_cats(s.SessionID) as LearnerTypess,
	case
		when NumAttendees IS not null then NumAttendees
		when NumEnrolled IS not null then NumEnrolled
		else null
	end as LearnerCount,
	dbo.total_sessions(s.SessionID) As SessionCount,
	coalesce(dbo.total_duration(s.sessionid), 0) as Duration,
	dbo.get_developers_by_session(a.ActivityID) as Developers,
	dbo.get_developer_units(a.ActivityID) as DeveloperUnits,
	dbo.get_presenters_by_session(s.SessionID) as Presenters,
	dbo.get_presenter_units(s.SessionID) as PresenterUnits,
	dbo.get_faculty_by_session(s.SessionID) AS FacContacts,
	dbo.build_initiatives(s.SessionID) as Initiatives
from 
	dbo.Session s
	join dbo.SessionActivity sa on s.SessionID = sa.SessionID
	join dbo.Activity a on sa.ActivityID = a.ActivityID
	join dbo.ActivityTypeLookup atl on a.ActivityTypeID = atl.ActivityTypeID
where SessionDateTime between '2015-07-01 00:00:00' and '2016-06-30 23:59:59'
order by SessionDateTime
