/*  PromptCat data for shelf-ready assessment.
    RR-353
*/

-- Bib records where 910 $a starts with PromptCat
with promptcat as (
  select distinct
    record_id as bib_id
  from vger_subfields.ucladb_bib_subfield
  where tag = '910a'
  and subfield like 'PromptCat%'
  --and record_id >= 5274085 -- first record created by promptcat
)
select 
  pc.bib_id
, trunc(bh.action_date) as create_date
, coalesce(bh.encoding_level, '#') as enc_lvl -- show # for blank
-- Days between bib creation and overlay by daily OCLC loader (if ever)
, round( (  select min(action_date) from bib_history
            where bib_id = bh.bib_id
            and operator_id = 'uclaloader'
    ) 
  - bh.action_date
) as days_to_catalog
-- Number of updates done by non-LIS locations
, ( select count(*) from bib_history
    where bib_id = bh.bib_id
    and action_type_id = 2 -- Update, which always has non-zero location_id
    and location_id != 203 -- lissystem
) as human_updates
, ( select count(*) from bib_history
    where bib_id = bh.bib_id
    and action_type_id = 2 -- Update, which always has non-zero location_id
    and operator_id = 'uclaloader'
) as uclaloader_updates
, vger_subfields.GetSubfields(pc.bib_id, '948a,948b') as f948ab
, vger_subfields.GetSubfields(pc.bib_id, '981b,981c') as f981bc
, vger_subfields.GetSubfields(pc.bib_id, '982b') as f982b
from promptcat pc
inner join bib_history bh
  on pc.bib_id = bh.bib_id
  and bh.action_type_id = 1 -- Create
  and bh.operator_id = 'promptcat'
order by pc.bib_id
;


