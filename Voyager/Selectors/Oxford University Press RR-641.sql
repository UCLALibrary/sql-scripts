select distinct 

bt.title,
bt.isbn,
bt.pub_dates_combined as pub_year,
bt.publisher as imprint


from ucla_bibtext_vw bt

where bt.publisher like 'Oxford University Press%'


order by bt.title
