/*  Selected data from mono bib records for various special collections locs
    VBT-1736 -> VBT-1741
*/

select distinct
  l.location_code
, bt.bib_id
-- Output spaces for tag/fld for LDR to use as a blank divider between records.
, case 
    when tag = 'LDR'
    then ' '
    else substr(bs.tag, 1, 3) 
end as tag
, case
    when tag = 'LDR'
    then cast(' ' as nvarchar2(1))
    else vger_subfields.getFieldFromSubfields(bs.record_id, bs.field_seq)
end as fld
from bib_text bt
inner join bib_mfhd bm on bt.bib_id = bm.bib_id
inner join mfhd_master mm on bm.mfhd_id = mm.mfhd_id
inner join location l on mm.location_id = l.location_id
inner join vger_subfields.ucladb_bib_subfield bs on bt.bib_id = bs.record_id
/*
-- Biomed
where l.location_code in (
  'bihi', 'bihimi', 'bihipam', 'birfhist', 'bisc', 'biscboxm', 'biscboxs', 'bisccg', 'bisccg*', 'bisccg**'
, 'biscrbr', 'biscrbr*', 'biscrbrb', 'biscvlt', 'biscvlt*', 'biscvlt**'
)
*/
/*
-- Music
where l.location_code in ('musc')
*/
/*
-- SRLF
where l.location_code in ('srar2', 'srbi2', 'sryr2', 'sryr7')
*/
--/*
-- YRL
where l.location_code in (
  'yrspald', 'yrspbcbc', 'yrspbelt', 'yrspbelt*', 'yrspbelt**', 'yrspbooth', 'yrspboxm', 'yrspboxs', 'yrspbro'
, 'yrspcoll', 'yrspinc', 'yrspmin', 'yrspo*', 'yrspo**', 'yrspo***', 'yrsprpr', 'yrspsafe', 'yrspstax', 'yrspvault'
)
--*/
and regexp_like(bt.bib_format, '[^p]m') -- monos which are not rec type p
and (
      bs.tag like '245%'
  or  bs.tag like '520%'
  or  bs.tag like '59%' -- any 59x
  or  bs.tag like '650%'
  or  bs.tag like '690%'
  or  bs.tag like '949%'
  or  bs.tag = 'LDR' -- used for divider between records
)
order by location_code, bib_id, tag
;

