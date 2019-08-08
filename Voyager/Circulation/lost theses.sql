SELECT
  bt.bib_id,
  vger_support.get_ocolc_number(bt.bib_id) AS ocolc_number,
  vger_support.unifix(title_brief) AS title_brief,
  ib.item_barcode AS barcode,
  mm.normalized_call_no,
  l.location_display_name,
  vger_support.get_bib_300(bt.bib_id) AS phys_desc,
  bt.publisher_date,
  isty.item_status_desc AS status,
  ist.item_status_date AS status_date
FROM
  ucladb.bib_text bt
  INNER JOIN ucladb.bib_item bi ON bt.bib_id = bi.bib_id
  INNER JOIN ucladb.item_status ist ON bi.item_id = ist.item_id
  INNER JOIN ucladb.item_status_type isty ON ist.item_status = isty.item_status_type
  INNER JOIN ucladb.item i ON bi.item_id = i.item_id
  INNER JOIN ucladb.item_barcode ib ON i.item_id = ib.item_id
  INNER JOIN ucladb.location l ON i.perm_location = l.location_id
  INNER JOIN ucladb.mfhd_item mi ON i.item_id = mi.item_id
  INNER JOIN ucladb.mfhd_master mm ON mi.mfhd_id = mm.mfhd_id
WHERE
  vger_support.is_ucla_dissertation(bt.bib_id) > 1
  AND ist.item_status IN (12,13,14)
