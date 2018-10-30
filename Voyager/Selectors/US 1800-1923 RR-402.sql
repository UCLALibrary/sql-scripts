/*  List of monographs published in the US from 1800-1923, for selected special collections locations.
    RR-402.
*/

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
from location l
inner join mfhd_master mm on l.location_id = mm.location_id
inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
inner join bib_text bt on bm.bib_id = bt.bib_id
-- Use valid values for lookup, but include rows where MARC has invalid code
left outer join vger_support.marc_place_codes pl on bt.place_code = pl.code
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
--and bt.place_code = 'cau' -- TESTING
order by l.location_code, mm.normalized_call_no
;
-- These two are invalid: 'muscspc', 'muscsdr'

-- Bad data, bad!
select sum(bibs) from (
select place_code, count(*) as bibs 
from bib_text bt 
where place_code like '__u' 
-- Compare to the list from LC, verified accurate
and not exists (select * from vger_support.marc_place_codes where code = bt.place_code)
group by place_code
order by place_code
)
;

