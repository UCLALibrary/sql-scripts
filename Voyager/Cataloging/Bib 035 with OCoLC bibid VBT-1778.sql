/*  Bib records where 035 $a (OCoLC) BIBID got created by WCM Mono update process.
    VBT-1778
*/

with d as (
select 
  bi.*
, (select begin_pub_date from bib_text where bib_id = bi.bib_id) as bdate
from bib_index bi
where index_code = '035A'
and display_heading like '(OCoLC)%'
and to_char(bib_id) = regexp_replace(normal_heading, '^0+', '')
and replace(translate(normal_heading, '0123456789', '0000000000'), '0', '') is null
--and bib_id < 1000000
) select count(*) from d;  --select bdate, count(*) from d group by bdate order by bdate
;

with d as (
  select
    bi.*
  , (select begin_pub_date from bib_text where bib_id = bi.bib_id) as bdate
  from bib_index bi
  where index_code = '0350'
  and to_char(bib_id) = normal_heading
) 
select count(*) from d
--select bdate, count(*) from d group by bdate order by bdate
--select * from d  where not exists (select * from bib_history where bib_id = d.bib_id and action_date > to_date('20200101', 'YYYYMMDD'))
;

select count(*) from bib_index where index_code = '0350' and normal_heading like 'UCOCLC%';
