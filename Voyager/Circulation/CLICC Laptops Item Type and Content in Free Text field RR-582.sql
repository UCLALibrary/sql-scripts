
select 
 itp.item_type_name --display
, mi.ITEM_ENUM
, ib.item_barcode
, mi.freetext
--, ino.item_note
--, ista.item_status_desc

FROM 
ITEM i
INNER JOIN LOCATION l ON i.PERM_LOCATION = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE
left outer JOIN ITEM_NOTE ino ON i.ITEM_ID = ino.ITEM_ID


where l.location_name like 'CLICC%'
    
     
      and itp.item_type_name = 'CLICC Laptop' 
    --  and ib.item_barcode like 'FAC%'
    --  and mi.item_enum like 'ITS MacBook%' 
          
        

order by ib.item_barcode 
 
