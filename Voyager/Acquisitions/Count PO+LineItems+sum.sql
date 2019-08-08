Enter file contents here
SELECT
v.vendor_name
--l.location_name
, Count (DISTINCT po.po_id) AS purchase_orders
, Count(li.line_item_id) AS line_items
, Sum(li.line_price/100) AS cost

FROM purchase_order po
INNER JOIN location l ON po.order_location = l.location_id
INNER JOIN po_type pt ON po.po_type = pt.po_type
INNER JOIN po_status ps ON po.po_status = ps.po_status
INNER JOIN line_item li ON po.po_id = li.po_id
INNER JOIN line_item_copy_status lics ON li.line_item_id = lics.line_item_id
inner join vendor v ON v.vendor_id = po.vendor_id


WHERE pt.po_type_desc = 'Firm Order'
AND (po.po_number NOT LIKE 'DCS%'  OR po.po_number NOT LIKE 'CDL%')
 --AND po.po_number NOT LIKE 'DCS%'


AND (ps.po_status_desc = 'Received Complete'
 OR ps.po_status_desc = 'Received Partial')
AND li.create_DATE BETWEEN to_date('2012-07-01', 'YYYY-MM-DD') and to_date('2013-07-01', 'YYYY-MM-DD')
AND (po.order_location = '550' OR po.order_location = '348' OR  po.order_location = '247')

GROUP BY
--BY l.location_name
v.vendor_name
