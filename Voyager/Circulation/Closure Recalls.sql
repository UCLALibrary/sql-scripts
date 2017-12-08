 SELECT /*+ ORDERED */
	(SELECT item_barcode FROM item_barcode WHERE item_id = hri.item_id AND barcode_status = 1 /*active*/) AS item_barcode
,	pb.patron_barcode AS current_patron
,	unifix(bt.author) as author
,	unifix(bt.title) as title
,	mi.item_enum as enum
,	i.copy_number as copy
,	(SELECT display_call_no FROM mfhd_master WHERE mfhd_id = mi.mfhd_id) AS call_number
FROM hold_recall hr
INNER JOIN hold_recall_items hri ON hr.hold_recall_id = hri.hold_recall_id
INNER JOIN bib_text bt ON hr.bib_id = bt.bib_id
LEFT OUTER JOIN circ_transactions ct ON hri.item_id = ct.item_id
INNER JOIN patron_barcode pb
	ON ct.patron_id = pb.patron_id
	AND ct.patron_group_id = pb.patron_group_id
	--AND pb.barcode_status = 1
INNER JOIN mfhd_item mi ON hri.item_id = mi.item_id
INNER JOIN item i ON hri.item_id = i.item_id
WHERE hr.hold_recall_type = 'R'
-- Starting date should be one day before the closure.
AND trunc(hr.create_date) >= trunc(to_date('2014-12-23', 'YYYY-MM-DD'))
-- Ending date should be one day after the closure.
AND trunc(hr.create_date) < trunc(to_date('2015-01-05', 'YYYY-MM-DD'))
-- Pick out the active patron barcode, or the one with the lowest number status
-- if there isn't an active one.
and not exists
(
  select * from ucladb.patron_barcode pb2
  where pb.patron_id = pb2.patron_id
  and (
        pb.barcode_status > pb2.barcode_status  or 
        (pb.barcode_status = pb2.barcode_status and pb2.patron_barcode_id < pb.patron_barcode_id)
      )
)
-- The documentation states we want "queue position 1" which means the entry
-- with the highest queue_position value so pick this out.
and not exists
(
  select * from hold_recall_items hri2
  where hri.item_id = hri2.item_id
  and hri2.queue_position > hri.queue_position
)
ORDER BY item_barcode, current_patron
