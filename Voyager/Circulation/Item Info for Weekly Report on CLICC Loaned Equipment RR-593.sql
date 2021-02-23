--See RR-574 Macs and RR-574 MiFi for exclusions

select distinct 
  itp.item_type_name
--, 'Chromebook' as Device  
--, mi.caption
, mi.item_enum
, ib.item_barcode
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
          and itp.item_type_name = 'CLICC Laptop' 
        --  and mi.caption = 'Chromebook'
      --  and mi.item_enum like 'ITS Windows Laptop%'
       and mi.item_enum like 'ITS iPad%' 
      --and mi.item_enum like 'ITS MacBook%' 
         --and ib.item_barcode like 'MI%'
       --   and ib.item_barcode like 'HP%' --and mi.item_enum like 'WL%') 
       --   and (mi.item_enum like 'ML%' and ib.item_barcode like 'MP%')

       
order by item_status_desc
--mi.item_enum, item_status_desc
