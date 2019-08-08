/*
1	UCLA Academic
8	UCLA Acad Proxy
12	UCLA Law Academic
13	UCLA Acad - NoLimit
38	UCLA Academic - DD
39	UCLA Acad NoLimit- DD
40	UCLA Acad Proxy - DD
48	UCLA Law Acad - DD
*/

SELECT
	bg.patron_group_display AS borrower_group,
	rg.patron_group_display AS recaller_group,
	count(cta.item_id) AS items_recalled
FROM
	ucladb.circ_trans_archive cta
	INNER JOIN ucladb.hold_recall_item_archive hria ON cta.item_id = hria.item_id 
	INNER JOIN ucladb.hold_recall_archive hra ON hria.hold_recall_id = hra.hold_recall_id
	LEFT OUTER JOIN ucladb.patron_group bg ON cta.patron_group_id = bg.patron_group_id
	LEFT OUTER JOIN ucladb.patron_group rg ON hra.patron_group_id = rg.patron_group_id
WHERE
	cta.patron_group_id IN (1,8,12,13,38,39,40,48)
	AND TRUNC(cta.charge_date) BETWEEN TRUNC(TO_DATE('07/01/2013','MM/DD/YYYY')) AND TRUNC(TO_DATE('06/30/2014','MM/DD?YYYY'))
	and cta.recall_date is not null
	AND upper(hria.hold_recall_type) = 'R'
	AND cta.recall_date = hra.create_date;
GROUP BY
	bg.patron_group_display,
	rg.patron_group_display

UNION

SELECT
	bg.patron_group_display AS borrower_group,
	rg.patron_group_display AS recaller_group,
	count(cta.item_id) AS items_recalled
FROM
	ucladb.circ_trans_archive cta
	INNER JOIN ucladb.hold_recall_items hria ON cta.item_id = hria.item_id 
	INNER JOIN ucladb.hold_recall hra ON hria.hold_recall_id = hra.hold_recall_id
	LEFT OUTER JOIN ucladb.patron_group bg ON cta.patron_group_id = bg.patron_group_id
	LEFT OUTER JOIN ucladb.patron_group rg ON hra.patron_group_id = rg.patron_group_id
WHERE
	cta.patron_group_id IN (1,8,12,13,38,39,40,48)
	AND TRUNC(cta.charge_date) BETWEEN TRUNC(TO_DATE('07/01/2013','MM/DD/YYYY')) AND TRUNC(TO_DATE('06/30/2014','MM/DD?YYYY'))
	and cta.recall_date is not null
	AND upper(hria.hold_recall_type) = 'R'
	AND cta.recall_date = hra.create_date;
GROUP BY
	bg.patron_group_display,
	rg.patron_group_display

UNION

SELECT
	bg.patron_group_display AS borrower_group,
	rg.patron_group_display AS recaller_group,
	count(cta.item_id) AS items_recalled
FROM
	ucladb.circ_transaction cta
	INNER JOIN ucladb.hold_recall_item_archive hria ON cta.item_id = hria.item_id 
	INNER JOIN ucladb.hold_recall_archive hra ON hria.hold_recall_id = hra.hold_recall_id
	LEFT OUTER JOIN ucladb.patron_group bg ON cta.patron_group_id = bg.patron_group_id
	LEFT OUTER JOIN ucladb.patron_group rg ON hra.patron_group_id = rg.patron_group_id
WHERE
	cta.patron_group_id IN (1,8,12,13,38,39,40,48)
	AND TRUNC(cta.charge_date) BETWEEN TRUNC(TO_DATE('07/01/2013','MM/DD/YYYY')) AND TRUNC(TO_DATE('06/30/2014','MM/DD?YYYY'))
	and cta.recall_date is not null
	AND upper(hria.hold_recall_type) = 'R'
	AND cta.recall_date = hra.create_date;
GROUP BY
	bg.patron_group_display,
	rg.patron_group_display

UNION

SELECT
	bg.patron_group_display AS borrower_group,
	rg.patron_group_display AS recaller_group,
	count(cta.item_id) AS items_recalled
FROM
	ucladb.circ_transaction cta
	INNER JOIN ucladb.hold_recall_items hria ON cta.item_id = hria.item_id 
	INNER JOIN ucladb.hold_recall hra ON hria.hold_recall_id = hra.hold_recall_id
	LEFT OUTER JOIN ucladb.patron_group bg ON cta.patron_group_id = bg.patron_group_id
	LEFT OUTER JOIN ucladb.patron_group rg ON hra.patron_group_id = rg.patron_group_id
WHERE
	cta.patron_group_id IN (1,8,12,13,38,39,40,48)
	AND TRUNC(cta.charge_date) BETWEEN TRUNC(TO_DATE('07/01/2013','MM/DD/YYYY')) AND TRUNC(TO_DATE('06/30/2014','MM/DD?YYYY'))
	and cta.recall_date is not null
	AND upper(hria.hold_recall_type) = 'R'
	AND cta.recall_date = hra.create_date;
GROUP BY
	bg.patron_group_display,
	rg.patron_group_display
ORDER BY
	borrower_group,
	recaller_group

/*
TOTAL TRANSACTIONS
1795
*/
