/*  Data for analysis of patron-initiated requests (PIA) by subject / LC class.
    https://jira.library.ucla.edu/browse/RR-224
    2016-10-28 akohler
*/

-- Run as vger_support due to permissions
select 
  pr.request_id
, pr.request_date
-- , pr.patron_id
, pr.bib_id
, mm.mfhd_id
, l.location_code
, mm.normalized_call_no
, mm.display_call_no
, ( select
      min(subject)
    from vger_support.call_number_subject_map
    where mm.normalized_call_no between norm_call_no_start and norm_call_no_end
    and subject_type = 'ERDB'
    and call_no_type = mm.call_no_type
) as class_subject
, ( select distinct
      first_value(subfield)
        over (partition by record_id order by tag, field_seq)
        as subfieldx
    from vger_subfields.ucladb_bib_subfield
    where record_id = pr.bib_id
    and tag like '65_a'
) as first_subject
, pr.patron_group
, pr.title_brief
from vger_support.pia_request pr
left outer join ucladb.bib_mfhd bm on pr.bib_id = bm.bib_id
left outer join ucladb.mfhd_master mm on bm.mfhd_id = mm.mfhd_id
left outer join ucladb.location l on mm.location_id = l.location_id
-- where pr.request_date between to_date('2015-04-01', 'YYYY-MM-DD') and to_date('2015-07-01', 'YYYY-MM-DD') -- 1026 for 4/1-6/30 2015
where pr.request_date between to_date('2016-04-01', 'YYYY-MM-DD') and to_date('2016-07-01', 'YYYY-MM-DD') -- 938 for 4/1-6/30 2016
order by normalized_call_no, location_code
;

-- Requests by month
select
  trunc(pr.request_date, 'MM') as request_month
, count(*) as requests
from vger_support.pia_request pr
group by trunc(pr.request_date, 'MM')
order by request_month
;

