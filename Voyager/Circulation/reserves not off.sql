SELECT DISTINCT
	rl.list_title,
	to_char(rl.expire_date, 'YYYY-MM-DD') AS expire_date,
	d.department_code,
	d.department_name,
	c.course_name,
	c.course_number
FROM
	ucladb.item i
	INNER JOIN ucladb.reserve_list_items rli ON i.item_id = rli.item_id
	INNER JOIN ucladb.reserve_list rl ON rli.reserve_list_id = rl.reserve_list_id
	INNER JOIN ucladb.reserve_list_courses rlc ON rl.reserve_list_id = rlc.reserve_list_id
	INNER JOIN ucladb.department d ON rlc.department_id = d.department_id
	INNER JOIN ucladb.course c ON rlc.course_id = c.course_id
WHERE
	i.on_reserve = 'Y'
	AND trunc(rl.expire_date) <= trunc(to_date(#prompt('DATE1')# ,'YYYY-MM-DD'))
