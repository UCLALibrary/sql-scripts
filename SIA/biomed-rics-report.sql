--SQL for Biomed RICS report, WEBSVCS-330 ticket
select
	ATL.ActivityType AS SessionType,
	S.SessionDateTime,
	dbo.get_developers_by_session(A.ActivityID) AS Developers,
	dbo.get_presenters_by_session(S.SessionID) AS Presenters,
	'"' + DL.Department + '"' AS LearnerAcademicDepartment,
	'"' + dbo.build_learner_cats(S.SessionID) + '"' as LearnerCategory,
	Coalesce(s.NumAttendees, s.NumEnrolled, 0) as NumberOfLearners,
	dbo.get_display_time(S.Duration) AS Duration,
	Coalesce(dbo.get_display_time(ADT.DevTime), 0) as DevTime,
	dbo.get_display_time(SPT.PrepTime) as PrepTime  
from
	dbo.Activity A
	inner join dbo.SessionActivity SA on A.ActivityID = SA.ActivityID
	inner join dbo.Session S on SA.SessionID = S.SessionID
	inner join dbo.ActivityTypeLookup ATL on A.ActivityTypeID = ATL.ActivityTypeID
	inner join dbo.DepartmentLookup DL on S.DepartmentID = DL.DepartmentID
	inner join dbo.ActivityLibrarian AL on A.ActivityID = AL.ActivityID
	inner join dbo.SessionLibrarian SL on S.SessionID = SL.SessionID
	left outer join dbo.ActivityDevelopmentTime ADT on A.ActivityID = ADT.ActivityID
	left outer join dbo.SessionPreparationTime SPT on S.SessionID = SPT.SessionID
where
	A.ActivityTypeID in (5,8)
	AND (AL.unitid = 2 OR SL.UnitID = 2)
	AND
	(
		(Datepart(Year, s.SessionDateTime) = 2013 AND Datepart(Month, s.SessionDateTime) BETWEEN 7 AND 12)
		OR (Datepart(Year, s.SessionDateTime) = 2014 AND Datepart(Month, s.SessionDateTime) BETWEEN 1 AND 6)
	)
order by
	SessionType,
	SessionDateTime,
	Developers,
	Presenters
