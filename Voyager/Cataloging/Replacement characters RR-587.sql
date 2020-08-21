/*  Bib records with U+FFFD (replacement character)
    with holdings in specified Clark / LSC locations.
    RR-587
*/

with bibs as (
  select distinct
    bm.bib_id
  , bm.mfhd_id
  , l.location_code
  from location l
  inner join mfhd_master mm on l.location_id = mm.location_id
  inner join bib_mfhd bm on mm.mfhd_id = bm.mfhd_id
  where l.location_code in (
    -- List of 90 codes from Excel; only 87 of them exist...
    'arsc', 'arscrr', 'arscsr', 'bihi', 'bihibjnl', 'bihibjnlwt', 'bihimi', 'bihipam', 'bihirest', 'birfhist', 
    'bisc', 'biscboxm', 'biscboxs', 'bisccg', 'bisccg*', 'bisccg**', 'bisccgma', 'biscrbr', 'biscrbr*', 'biscrbrb', 
    'biscsr', 'biscvlt', 'biscvlt*', 'biscvlt**', 'musc', 'musc*', 'musc**', 'musc***', 'muscfacs', 'muscmanu', 
    'muscmini', 'muscobl', 'muscoblfac', 'muscrf', 'muscsheet', 'muscsr', 'muscstax', 'musctoc', 'musctoc*', 'srar2', 
    'srbi2', 'sryr2', 'sryr7', 'uaref', 'uasr', 'yrscacq', 'yrspalc', 'yrspald', 'yrspback', 'yrspbcbc', 
    'yrspbcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbelt**', 'yrspbooth', 'yrspboxm', 'yrspboxs', 'yrspbro', 'yrspcat', 'yrspcbc', 
    'yrspcbc*', 'yrspcoll', 'yrspdh', 'yrspeip', 'yrspeip*', 'yrspeip**', 'yrspinc', 'yrspmin', 'yrspo*', 'yrspo**', 
    'yrspo***', 'yrsprpr', 'yrspsafe', 'yrspsr', 'yrspstax', 'yrspvault', 'ck', 'ck3a', 'ckacq', 'ckart1', 
    'ckarta', 'ckartb', 'ckcage', 'ckcat', 'ckmap', 'ckmt', 'ckpress', 'ckrf', 'ckrr', 'srck'
  )
)
select
  b.*
, bs.tag
, bs.subfield
from bibs b
inner join vger_subfields.ucladb_bib_subfield bs on b.bib_id = bs.record_id
where subfield like unistr('%\fffd%')
order by b.location_code
;
--3680

select count(*) 
from vger_subfields.ucladb_bib_subfield
where subfield like unistr('%\fffd%')
;