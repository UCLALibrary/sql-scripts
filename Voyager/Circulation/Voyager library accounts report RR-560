 
 select
   pa.normal_last_name as last_name
 , pa.normal_first_name as first_name
 --library  card number?
 , pa.normal_institution_id as institution_id
 , pb.patron_barcode
 , pg.patron_group_name
 , pa.expire_date
 
 from patron pa
  
 INNER JOIN PATRON_BARCODE pb on pa.PATRON_ID = pb.PATRON_ID
 INNER JOIN PATRON_GROUP pg ON pb.PATRON_GROUP_ID = pg.PATRON_GROUP_ID
 
 where pa.expire_date > to_date('20211231', 'YYYYMMDD')
  
 
-- where pa.normal_last_name like 'WILLOUGHBY%'
 
 order by pa.normal_last_name
