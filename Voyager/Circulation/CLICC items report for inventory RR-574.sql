select

 distinct itp.item_type_name
, 'Chromebook' as Device  
, ista.item_status_desc
, Count(ista.item_status_desc) AS count


FROM
ITEM i
INNER JOIN LOCATION l ON i.PERM_LOCATION = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE


where l.location_name like 'CLICC%'

    
      and itp.item_type_name = 'CLICC Laptop' 
          and mi.caption = 'Chromebook'

group by

  itp.item_type_name
, ista.item_status_desc

        UNION ALL
        
        select

 distinct itp.item_type_name
, 'ITS Windows Laptop' as Device  
, ista.item_status_desc
, Count(ista.item_status_desc) AS count


FROM
ITEM i
INNER JOIN LOCATION l ON i.PERM_LOCATION = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE


where l.location_name like 'CLICC%'

   

       and itp.item_type_name = 'CLICC Laptop' 
       and mi.item_enum like 'ITS Windows Laptop%' 

group by

  itp.item_type_name
, ista.item_status_desc

            UNION ALL
            
            select

 distinct itp.item_type_name
, 'ITS iPad' as Device  
, ista.item_status_desc
, Count(ista.item_status_desc) AS count


FROM
ITEM i
INNER JOIN LOCATION l ON i.PERM_LOCATION = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE


where l.location_name like 'CLICC%'

         
      and itp.item_type_name = 'CLICC Laptop' 
      and mi.item_enum like 'ITS iPad%' 

group by

  itp.item_type_name
, ista.item_status_desc

            UNION ALL
            
            select

 distinct itp.item_type_name
, 'ITS MacBook' as Device  
, ista.item_status_desc
, Count(ista.item_status_desc) AS count


FROM
ITEM i
INNER JOIN LOCATION l ON i.PERM_LOCATION = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE


where l.location_name like 'CLICC%'

   
      and itp.item_type_name = 'CLICC Laptop' 
      and mi.item_enum like 'ITS MacBook%' 

group by

  itp.item_type_name
, ista.item_status_desc

            UNION ALL
            
            select

 distinct itp.item_type_name
, 'CLICC MiFi' as Device  
, ista.item_status_desc
, Count(ista.item_status_desc) AS count


FROM
ITEM i
INNER JOIN LOCATION l ON i.PERM_LOCATION = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE


where l.location_name like 'CLICC%'

        and ib.item_barcode like 'MI%'

group by

  itp.item_type_name
, ista.item_status_desc

            UNION ALL
            
            select

 distinct itp.item_type_name
, 'CLICC HP' as Device  
, ista.item_status_desc
, Count(ista.item_status_desc) AS count


FROM
ITEM i
INNER JOIN LOCATION l ON i.PERM_LOCATION = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE


where l.location_name like 'CLICC%'

      and itp.item_type_name = 'CLICC Laptop' 
      and ib.item_barcode like 'HP%'
      and mi.item_enum like 'WL%' 

group by

  itp.item_type_name
, ista.item_status_desc

            UNION ALL

select

 distinct itp.item_type_name
, 'CLICC Mac' as Device  
, ista.item_status_desc
, Count(ista.item_status_desc) AS count


FROM
ITEM i
INNER JOIN LOCATION l ON i.PERM_LOCATION = l.LOCATION_ID
INNER JOIN MFHD_ITEM mi ON i.ITEM_ID = mi.ITEM_ID

inner join item_type itp on i.item_type_id = itp.item_type_id
inner join item_barcode ib on i.item_id = ib.item_id
INNER JOIN ITEM_STATUS ist ON i.ITEM_ID = ist.ITEM_ID
INNER JOIN ITEM_STATUS_TYPE ista ON ist.ITEM_STATUS = ista.ITEM_STATUS_TYPE


where l.location_name like 'CLICC%'

     and itp.item_type_name = 'CLICC Laptop' 
     and mi.item_enum like 'ML%'
     and ib.item_barcode like 'MP%'

group by

  itp.item_type_name
, ista.item_status_desc
            

order by Device, item_status_desc 

