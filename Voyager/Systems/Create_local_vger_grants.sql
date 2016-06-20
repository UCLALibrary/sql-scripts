/*Grant SELECT privilege on all Voyager database tables to vger_support and vger_report
	Grant EXECUTE privilege on Voyager database functions to vger_support and vger_report
	Grant EXECUTE privilege on Voyager database functions in UCLADB to ucla_preaddb
	Must be run by user with DBA privileges (like UCLADB, currently)
	Takes 5-6 minutes to run
	2006-07-31 akohler: created
	2006-08-18 akohler: added vger_report to list of target users
	2006-12-14 akohler: added "with grant option" to allow target users to grant privileges on views created on underlying voyager objects
	2007-04-12 akohler: added execute function privileges
	2007-06-18 akohler: added ucla_preaddb to list of target users, to use as universal read-only Voyager account
	2007-12-11 akohler: rewrote to use all_objects instead of all_tables etc.
	2008-07-05 akohler: filter out 10g recycle bin objects
*/
DECLARE
	m_owner all_objects.owner%TYPE;
	m_object_name all_objects.object_name%TYPE;
	m_object_type all_objects.object_type%TYPE;

	m_action VARCHAR2(10);
	m_target_users VARCHAR2(50); -- comma-delimited list of users
	m_sql VARCHAR2(200);

	CURSOR objects IS
		SELECT owner, object_name, object_type
		FROM all_objects
		WHERE owner IN ('ETHNODB', 'FILMNTVDB', 'UCLADB', 'VGER_SUBFIELDS')
		AND object_type IN ('FUNCTION', 'PACKAGE', 'TABLE', 'VIEW')
		AND status = 'VALID'
		AND object_name NOT LIKE 'BIN$%' -- filter out 10g recyle bin objects
		ORDER BY owner, object_name
		;
BEGIN
	m_target_users := 'ucla_preaddb, vger_report, vger_support';

	OPEN objects;
	LOOP
		FETCH objects INTO m_owner, m_object_name, m_object_type;
		CASE
			WHEN m_object_type IN ('FUNCTION', 'PACKAGE') THEN m_action := 'execute';
			WHEN m_object_type IN ('TABLE', 'VIEW') THEN m_action := 'select';
		END CASE;
		m_sql := 'grant ' || m_action || ' on ' || m_owner || '.' || m_object_name || ' to ' || m_target_users || ' with grant option';
		--Dbms_Output.put_line(m_sql);
		EXECUTE IMMEDIATE m_sql;
		EXIT WHEN objects%NOTFOUND;
	END LOOP;
	CLOSE objects;
END;
/

