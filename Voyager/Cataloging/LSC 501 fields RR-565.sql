/*  LSC records with 501 fields.
    RR-565
*/

with bibs as (
  select 
    record_id as bib_id
  , field_seq
  , ( select subfield from vger_subfields.ucladb_bib_subfield
      where record_id = bs.record_id
      and field_seq = bs.field_seq
      and tag = '5015'
    ) as f5015
  , subfield as f501a
  from vger_subfields.ucladb_bib_subfield bs
  -- All relevant records have 501 $a
  where tag like '501a'
)
select
  b.bib_id
, l.location_code
, b.f5015
, b.f501a
from bibs b
inner join bib_mfhd bm on b.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
where l.location_code in (
  'arsc', 'arscrr', 'arscsr', 'bihi', 'bihibjnl', 'bihibjnlwt', 'bihimi', 'bihipam', 'bihirest', 'birfhist', 
  'bisc', 'biscboxm', 'biscboxs', 'bisccg', 'bisccg*', 'bisccg**', 'bisccgma', 'biscrbr', 'biscrbr*', 'biscrbrb', 
  'biscsr', 'biscvlt', 'biscvlt*', 'biscvlt**', 'musc', 'musc*', 'musc**', 'musc***', 'muscfacs', 'muscmanu', 
  'muscmini', 'muscobl', 'muscoblfac', 'muscrf', 'muscsheet', 'muscsr', 'muscstax', 'musctoc', 'musctoc*', 'srar2', 
  'srbi2', 'sryr2', 'sryr7', 'uaref', 'uasr', 'yrscacq', 'yrspalc', 'yrspald', 'yrspback', 'yrspbcbc', 'yrspbcbc*', 
  'yrspbelt', 'yrspbelt*', 'yrspbelt**', 'yrspbooth', 'yrspboxm', 'yrspboxs', 'yrspbro', 'yrspcat', 'yrspcbc', 'yrspcbc*', 
  'yrspcoll', 'yrspdh', 'yrspeip', 'yrspeip*', 'yrspeip**', 'yrspinc', 'yrspmin', 'yrspo*', 'yrspo**', 'yrspo***', 
  'yrsprpr', 'yrspsafe', 'yrspsr', 'yrspstax', 'yrspvault'
)
order by f501a
;
