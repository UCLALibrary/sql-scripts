--USE THIS - THIS IS THE GOOD ONE! LW OCT 2013
SELECT  DISTINCT
--  mm.normalized_call_no
  mm.display_call_no
, bt.bib_id
, bt.isbn
, vger_support.unifix(author) as author
, vger_support.unifix(title) as title
, bt.publisher
, location_code
, l.location_name
, bt.pub_dates_combined as pub_date
, ucladb.getallbibtag(bt.bib_id, '650') AS f650_subjects --f650all
, ucladb.getbibtag(bt.Bib_id, '655') AS f655
, ucladb.getbibtag(bt.Bib_id, '500') AS f_500_notes
, ucladb.getbibtag(bt.Bib_id, '505') AS f505
, ucladb.getbibtag(bt.Bib_id, '520') AS f520
, ucladb.getbibtag(bt.Bib_id, '700') AS f700
--, ucladb.getbibtag(bt.Bib_id, '300') AS phys_desc

--505, 520, 650, 655, 700
--, ucladb.getbibtag(bt.Bib_id, '380') AS form_of_work
--, ucladb.getbibtag(bt.Bib_id, '650') AS subject,


FROM ucla_bibtext_vw bt

inner JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
left outer JOIN MFHD_MASTER  mm on bmf.MFHD_ID = mm.MFHD_ID
inner JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID 


             where l.location_code = 'clcook'
                   

ORDER BY mm.display_call_no
