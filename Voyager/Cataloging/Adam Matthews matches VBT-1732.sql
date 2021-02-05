/*  Voyager records matching a file of Adam Matthews records, for OCLC holdings maintenance.
    VBT-1732
*/

-- Excel data first imported to vger_report.tmp_adams_vbt1732

select 
  a.oclc_number
--, bi.normal_heading
, bi.bib_id
, case
    when exists (
      select * from vger_subfields.ucladb_bib_subfield
      where record_id = bi.bib_id
      and tag = '856x'
      and subfield != 'CDL'
    )
    then 'Y'
    else 'N'
end as has_non_cdl
, case
    when exists (
      select * from ucladb.bib_location bl
      inner join ucladb.location l on bl.location_id = l.location_id
      where bl.bib_id = bi.bib_id
      and l.location_code != 'in'
    )
    then 'Y'
    else 'N'
end as has_physical
, a.publication_title
--, bt.title
from vger_report.tmp_adams_vbt1732 a
inner join ucladb.bib_index bi on 'UCOCLC' || a.oclc_number = bi.normal_heading and bi.index_code = '0350'
--inner join ucladb.bib_text bt on bi.bib_id = bt.bib_id
;
-- Some have both 856 $x CDL and others, like bib 6627444
-- 649 rows from Excel; 124 match Voyager

drop table vger_report.tmp_adams_vbt1732 purge;