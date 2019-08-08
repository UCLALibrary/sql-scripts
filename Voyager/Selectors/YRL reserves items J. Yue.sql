SELECT
  --  i.item_id,
  --  bi.bib_id,
    iv.barcode AS item_barcode,
    bt.title,
    bt.author,
    iv.call_no AS call_no,
  --  iv.enumeration AS enumeration,
    it.item_type_name AS item_type,
    itt.item_type_name AS temp_item_type,
  --  ino.item_note,
    iv.perm_location,
    lt.location_name AS temp_location,
    rl.list_title,
    rlc.section_id,
    rl.effect_date AS list_starts,
    rl.expire_date AS list_ends


FROM
    ucladb.item i
    inner join ucladb.bib_item bi ON i.item_id = bi.item_id
    inner join ucladb.bib_text bt ON bi.bib_id = bt.bib_id
    inner join ucladb.item_vw iv ON bi.item_id = iv.item_id
    inner join ucladb.reserve_list_items rli ON i.item_id = rli.item_id
    inner join ucladb.reserve_list rl ON rli.reserve_list_id = rl.reserve_list_id
    INNER JOIN RESERVE_LIST_COURSES rlc ON rl.RESERVE_LIST_ID = rlc.RESERVE_LIST_ID

    inner join ucladb.item_type it ON i.item_type_id = it.item_type_id
    inner join ucladb.location lr ON rl.reserve_location = lr.location_id
    left outer join ucladb.item_note ino ON i.item_id = ino.item_id
    left outer join ucladb.location lt ON i.temp_location = lt.location_id
    left outer join ucladb.hold_recall_items hri ON i.item_id = hri.item_id
    left outer join ucladb.hold_recall hr ON hri.hold_recall_id = hr.hold_recall_id
    left outer join ucladb.patron pr ON hr.patron_id = pr.patron_id
    left outer join ucladb.circ_transactions ct ON i.item_id = ct.item_id
    left outer join ucladb.patron pc ON ct.patron_id = pc.patron_id
    left outer join ucladb.item_status is_m ON i.item_id = is_m.item_id AND is_m.item_status = 12
    left outer join ucladb.item_status is_p ON i.item_id = is_p.item_id AND is_p.item_status = 22
    left outer join ucladb.item_status is_o ON i.item_id = is_o.item_id AND (is_o.item_status = 6 OR is_o.item_status = 15)
    left outer join ucladb.item_status_type ist ON is_o.item_status = ist.item_status_type
    left outer join ucladb.item_type itt ON i.temp_item_type_id = itt.item_type_id
    left outer join ucladb.bib_master bm on bi.bib_id = bm.bib_id
    left outer join ucladb.mfhd_item mi on i.item_id = mi.item_id
    left outer join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
WHERE
    rl.effect_date > to_date('20110915', 'YYYYMMDD')
    --rl.expire_date >= SYSDATE
    --AND rl.expire_date >= SYSDATE
    AND lt.location_name like  'YRL%'
    ORDER BY iv.call_no--item_barcode
