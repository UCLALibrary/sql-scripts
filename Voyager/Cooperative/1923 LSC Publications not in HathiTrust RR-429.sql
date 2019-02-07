/*  Match some Voyager data against OCLC numbers from HathiTrust.
    Downloaded full 20190201 file from https://www.hathitrust.org/hathifiles;
    unzipped and extracted unique OCLC number values:
    cat hathi_full_20190201.txt | cut -f8 | sort -u > hathi_oclc.lst
    
    That gives 8256614 unique values.  Some are compound, separated by commas, like 10000285,214226819.
    Put the compound values in separate file:
    $ grep "," hathi_oclc.lst > hathi_oclc_comma.lst
    
    Used shell script to split OCLC strings into real values, then imported into working table.
    
    # split_comma.sh
    cat hathi_oclc_comma.lst | \
    while IFS=',' read -ra LINE; do
      for OCLC in "${LINE[@]}"; do
        echo $OCLC
      done
    done
    
    $ grep -v "," hathi_oclc.lst > hathi_single_unsorted.lst
    $ ./split_comma.sh >> hathi_single_unsorted.lst
    $ sort -u hathi_single_unsorted.lst > hathi_single_sorted.lst
    $ vger_sqlldr_load vger_report hathi_single_sorted.lst hathi.ctl
    
    # hathi.ctl
    LOAD DATA
    TRUNCATE
    INTO TABLE vger_report.tmp_rr_429_import
    FIELDS TERMINATED BY x'0D'
    TRAILING NULLCOLS
    ( oclc_string
    )
   
    Re-run RR-402 query, find OCLC numbers in Voyager for them, compare to Hathi list.
    
    RR-429; related to RR-402.
*/

drop table vger_report.tmp_rr_429_import purge;
create table vger_report.tmp_rr_429_import (
  oclc_string varchar2(15) not null
)
;
create index vger_report.ix_tmp_rr_429_oclc on vger_report.tmp_rr_429_import (oclc_string);

select count(*) from vger_report.tmp_rr_429_import;
-- 8491124 non-null rows imported

-- Re-run query from RR-402, filtering with Hathi OCLC
select 
  l.location_code
, mm.display_call_no
, vger_subfields.GetSubfields(mm.mfhd_id, '852x', 'mfhd', 'ucladb') as f852x
, vger_subfields.GetSubfields(mm.mfhd_id, '852z', 'mfhd', 'ucladb') as f852z
, mm.mfhd_id
, bt.bib_id
, bt.place_code
, pl.name as place_name
, bt.pub_dates_combined as pub_dates
, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title_brief) as title_brief
, vger_support.unifix(bt.imprint) as imprint
, vger_subfields.GetSubfields(bt.bib_id, '300a', 'bib', 'ucladb') as f300a
, replace(bi.normal_heading, 'UCOCLC', '') as vger_oclc
, o.oclc_string as hathi_oclc
from ucladb.location l
inner join ucladb.mfhd_master mm on l.location_id = mm.location_id
inner join ucladb.bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt on bm.bib_id = bt.bib_id
-- Use valid values for lookup, but include rows where MARC has invalid code
left outer join vger_support.marc_place_codes pl on bt.place_code = pl.code
-- Not all bibs have OCLC numbers
left outer join ucladb.bib_index bi
  on bt.bib_id = bi.bib_id
  and bi.index_code = '0350'
  and bi.normal_heading like 'UCOCLC%'
-- Get Voyager records which don't match Hathi on OCLC
left outer join vger_report.tmp_rr_429_import o
  on replace(bi.normal_heading, 'UCOCLC', '') = o.oclc_string
where l.location_code in (
  'arsc', 'arscrr', 'bihimi', 'bihipam', 'bihirest', 'bisc', 'bisccg', 'bisccg*', 'bisccg**', 'bisccgma'
, 'biscrbr', 'biscrbr*', 'biscrbrb', 'biscvlt', 'biscvlt*', 'biscvlt**', 'musc', 'musc*', 'musc**', 'musc***'
, 'muscfacs', 'muscfolio', 'muscmanu', 'muscmini', 'muscobl', 'muscoblfac', 'muscrf', 'muscsdr', 'muscsheet', 'muscspc'
, 'muscsr', 'musctoc', 'musctoc*', 'srar2', 'srbi2', 'sryr2', 'sryr7', 'uaref', 'yrspald', 'yrspback'
, 'yrspbcbc', 'yrspbcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbooth', 'yrspboxm', 'yrspboxs', 'yrspbro', 'yrspcat', 'yrspcbc'
, 'yrspcbc*', 'yrspeip', 'yrspeip*', 'yrspeip**', 'yrspmin', 'yrspo*', 'yrspo**', 'yrspo***', 'yrsprpr', 'yrspstax', 'yrspvault'
)
--and pl.code like '__u' -- 3 characters, ending with 'u', are all US publications; this gets the valid ones only, as several hundred are wrong
and bt.place_code like '__u' -- this gets the bad ones too......
and bt.begin_pub_date between '1800' and '1923'
and bt.bib_format like '%m'
--and bi.normal_heading is null
and o.oclc_string is null
order by l.location_code, mm.normalized_call_no
;
-- 747 bibs have no OCLC number from current Voyager data
-- 19891 bibs have no match in Hathi on OCLC

