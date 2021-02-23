
select 
  --itp.item_type_name 
  mi.ITEM_ENUM
, ib.item_barcode
--, mi.caption
, ista.item_status_desc


FROM 
ITEM i
INNER JOIN LOCATION l ON i.PERM_LOCATION = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE

where l.location_name like 'CLICC%'
     
      --and itp.item_type_name = 'CLICC Laptop' 
      --and mi.caption = 'Chromebook'
      and (ista.item_status_desc = 'In Transit Discharged' or ista.item_status_desc = 'Discharged')
          
      and (ib.item_barcode like 'CBK%'
        or ib.item_barcode like 'HP%'
        or ib.item_barcode like 'MP%'
        or mi.ITEM_ENUM like 'ITS MacBook%'
        or mi.ITEM_ENUM like 'ITS iPad%')
    
 
    

order by ib.item_barcode 
 
