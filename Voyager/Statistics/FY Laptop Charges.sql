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
