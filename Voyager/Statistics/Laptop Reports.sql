AVERAGE CHARGES

WITH laptop_counts AS
(
  SELECT 
    cta.charge_location, 
    trunc(cta.charge_date) AS charge_date, 
    COUNT(cta.item_id) AS laptops
  FROM 
    ucladb.circ_trans_archive cta
    INNER JOIN ucladb.item i ON cta.item_id = i.item_id
  WHERE 
    i.item_type_id = 50
  GROUP BY 
    cta.charge_location, 
    trunc(cta.charge_date)
  UNION
  SELECT 
    ct.charge_location, 
    trunc(ct.charge_date) AS charge_date, 
    COUNT(ct.item_id) AS laptops
  FROM 
    ucladb.circ_transactions ct
    INNER JOIN ucladb.item i ON ct.item_id = i.item_id
  WHERE 
    i.item_type_id = 50
  GROUP BY 
    ct.charge_location, 
    trunc(ct.charge_date)
)
SELECT
	l.location_name,
	floor(AVG(lc.laptops)) AS avg_laptops
FROM
	laptop_counts lc
        LEFT OUTER JOIN ucladb.location l ON lc.charge_location = l.location_id
WHERE
	lc.charge_date BETWEEN trunc(to_date(#prompt('START')#, 'YYYY-MM-DD')) AND trunc(to_date(#prompt('END')#, 'YYYY-MM-DD'))
GROUP BY
	l.location_name,
        lc.charge_location


HISTORICAL CHARGES
SELECT 
  nvl(p.institution_id, 'N/A') as institution_id,
  pg.patron_group_display,
  l.location_name AS charge_location,
  count(cta.circ_transaction_id) AS charges
FROM
  ucladb.item i
  INNER JOIN ucladb.circ_trans_archive cta ON i.item_id = cta.item_id
  INNER JOIN ucladb.patron_group pg ON cta.patron_group_id = pg.patron_group_id
  INNER JOIN ucladb.location l ON cta.charge_location = l.location_id
  LEFT JOIN ucladb.patron p ON cta.patron_id = p.patron_id
WHERE
  i.item_type_id = 50
  AND trunc(cta.charge_date) between trunc(to_date(#prompt('DATE1')#,'YYYY-MM-DD')) 
                                                        AND trunc(to_date(#prompt('DATE2')#,'YYYY-MM-DD'))
GROUP BY
  p.institution_id,
  pg.patron_group_display,
  l.location_name

DATE/PLACE CHARGES
SELECT DISTINCT
	#prompt('STARTDAY')# AS start_date,
	#prompt('ENDDAY')# AS end_date,
	l.location_name,
	vger_support.laptop_trans_date_place(i.perm_location,#prompt('STARTDAY')#,#prompt('ENDDAY')#) AS charges
FROM 
	ucladb.item i
	INNER JOIN ucladb.location l ON i.perm_location = l.location_id
WHERE
	i.item_type_id = 50


TOP BORROWERS
SELECT 
  nvl(p.institution_id, 'N/A') as institution_id,
  pg.patron_group_display,
  count(cta.circ_transaction_id) AS charges
FROM
  ucladb.item i
  INNER JOIN ucladb.circ_trans_archive cta ON i.item_id = cta.item_id
  INNER JOIN ucladb.patron_group pg ON cta.patron_group_id = pg.patron_group_id
  LEFT JOIN ucladb.patron p ON cta.patron_id = p.patron_id
WHERE
  i.item_type_id = 50
GROUP BY
  p.institution_id,
  pg.patron_group_display

IPADS
SELECT 
  nvl(p.institution_id, 'N/A') as institution_id,
  pg.patron_group_display,
  l.location_name AS charge_location,
  count(cta.circ_transaction_id) AS charges
FROM
  ucladb.item i
  INNER JOIN ucladb.circ_trans_archive cta ON i.item_id = cta.item_id
  INNER JOIN ucladb.patron_group pg ON cta.patron_group_id = pg.patron_group_id
  INNER JOIN ucladb.location l ON cta.charge_location = l.location_id
  LEFT JOIN ucladb.patron p ON cta.patron_id = p.patron_id
WHERE
  i.item_type_id = 64
  AND trunc(cta.charge_date) between trunc(to_date(#prompt('DATE1')#,'YYYY-MM-DD')) 
                                                        AND trunc(to_date(#prompt('DATE2')#,'YYYY-MM-DD'))
GROUP BY
  p.institution_id,
  pg.patron_group_display,
  l.location_name

RENEWALS
SELECT  DISTINCT
il.location_name AS item_location,
Count (rta.renew_Date) AS renewals

FROM ucladb.circ_trans_archive cta
INNER JOIN ucladb.renew_trans_archive rta ON cta.circ_transaction_id = rta.circ_transaction_id
inner JOIN ucladb.location tl ON tl.location_id = rta.renew_location
INNER JOIN ucladb.item i ON i.item_id = cta.item_id
inner JOIN ucladb.location il ON il.location_id = i.perm_location

WHERE i.item_type_id = 50 
        AND rta.renew_date 
	BETWEEN 
	--#prompt('DATE_1')# and #prompt('DATE_2')#
	to_date(#prompt('date_1')#, 'YYYY-MM-DD')
	and
	to_date(#prompt('date_2')#, 'YYYY-MM-DD')
GROUP BY il.location_name,
         i.recalls_placed


FISCAL YEAR CHARGES
SELECT
  p.institution_id,
  pg.patron_group_display,
  vger_support.get_all_patron_stat_codes(p.patron_id, ',') AS patron_stat_codes,
  mi.item_enum,
  cta.charge_date,
  lc.location_name AS charge_place,
  cta.discharge_date,
  null AS discharge_place
FROM
  ucladb.item i
  INNER JOIN ucladb.circ_transactions cta ON i.item_id = cta.item_id
  INNER JOIN ucladb.patron p ON cta.patron_id = p.patron_id
  INNER JOIN ucladb.patron_group pg ON cta.patron_group_id = pg.patron_group_id
  INNER JOIN ucladb.location lc ON cta.charge_location = lc.location_id
  INNER JOIN ucladb.location ld ON cta.discharge_location = ld.location_id
  INNER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
WHERE
  i.item_type_id = 50
  AND trunc(cta.charge_date) between trunc(to_date(#prompt('DATE1')#,'YYYY-MM-DD')) 
  AND trunc(to_date(#prompt('DATE2')#,'YYYY-MM-DD'))
UNION
SELECT
  p.institution_id,
  pg.patron_group_display,
  vger_support.get_all_patron_stat_codes(p.patron_id, ',') AS patron_stat_codes,
  mi.item_enum,
  cta.charge_date,
  lc.location_name AS charge_place,
  cta.discharge_date,
  ld.location_name AS discharge_place
FROM
  ucladb.item i
  INNER JOIN ucladb.circ_trans_archive cta ON i.item_id = cta.item_id
  INNER JOIN ucladb.patron p ON cta.patron_id = p.patron_id
  INNER JOIN ucladb.patron_group pg ON cta.patron_group_id = pg.patron_group_id
  INNER JOIN ucladb.location lc ON cta.charge_location = lc.location_id
  INNER JOIN ucladb.location ld ON cta.discharge_location = ld.location_id
  INNER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
WHERE
  i.item_type_id = 50
  AND trunc(cta.charge_date) between trunc(to_date(#prompt('DATE1')#,'YYYY-MM-DD')) 
  AND trunc(to_date(#prompt('DATE2')#,'YYYY-MM-DD'))
  
