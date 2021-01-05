--RR-634

SELECT DISTINCT
bt.bib_id,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
ib.item_barcode,
bt.title,
bt.author,
mm.display_call_no,
--l.location_name,
mi.item_enum,
i.copy_number,
ista.item_status_desc,
pg.patron_group_name,
pb.patron_barcode,
( select listagg(l2.location_code, ', ') within group (order by l2.location_code)
    from bib_location bl
    inner join location l2 on bl.location_id = l2.location_id
    where bl.bib_id = bt.bib_id
    and l2.location_code != l.location_code
) as other_locs,
ff.fine_fee_amount/100 as fine_fee,
ff.fine_fee_balance/100 as fine_balance

FROM ucla_BIBTEXT_vw bt

INNER join BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
INNER join MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
inner join LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID
inner join MFHD_ITEM mi ON mm.MFHD_ID = mi.MFHD_ID
inner join ITEM i ON mi.ITEM_ID = i.ITEM_ID
inner join item_barcode ib on i.item_id = ib.item_id
inner join ITEM_TYPE it ON i.ITEM_TYPE_ID = it.ITEM_TYPE_ID
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID 
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE
left outer JOIN FINE_FEE ff ON i.ITEM_ID = ff.ITEM_ID
left outer JOIN PATRON p ON ff.PATRON_ID = p.PATRON_ID
left outer JOIN PATRON_BARCODE pb ON p.PATRON_ID = pb.PATRON_ID
left outer JOIN PATRON_GROUP pg ON pb.PATRON_GROUP_ID = pg.PATRON_GROUP_ID





left outer join CIRC_TRANS_archive ct ON i.ITEM_ID = ct.ITEM_ID

WHERE l.location_code = 'clsustain'
     
  order by mm.display_call_no
        
        



            
            
            
            

