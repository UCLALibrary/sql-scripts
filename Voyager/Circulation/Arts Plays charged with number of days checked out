SELECT 
bt.title,
mm.display_call_no,
l.location_code,
ib.item_barcode,
iti.item_type_name,
istat.item_status_desc,
To_Char (ct.charge_date,'fmMM/DD/YYYY') AS charge_date,
To_Char (ct.charge_due_date, 'fmMM/DD/YYYY') as due_date,
round((sysdate)-ct.charge_date) as days_checked_out

FROM ucla_BIBTEXT_vw bt

INNER join BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER join MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
INNER join LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
INNER join MFHD_ITEM mi ON mm.MFHD_ID = mi.MFHD_ID
INNER join ITEM i ON mi.ITEM_ID = i.ITEM_ID
inner join item_barcode ib on i.item_id = ib.item_id
inner join item_type iti on i.item_type_id  = iti.item_type_id
inner join item_status ista on i.item_id = ista.item_id
inner join item_status_type istat on ista.item_status = istat.item_status_type
INNER join circ_transactions ct ON i.ITEM_ID = ct.ITEM_ID

WHERE       l.location_code = 'arplay'
            and istat.item_status_desc = 'Charged'
           -- and ct.charge_date >= to_date('20190101', 'YYYYMMDD')
            
            order by 
            --ct.discharge_date
            ct.charge_date

      


