/*  Report(s) of CDL licensed resources, based on 856 field(s).
    RR-469
*/

-- Start with UCLA 856 fields - excluding Law-specific ones
with ucla_856 as (
  select record_id, field_seq 
  from vger_subfields.ucladb_bib_subfield 
  where tag = '856z'
  and upper(subfield) like '%RESTRICTED TO UCLA%'
  minus
  select record_id, field_seq 
  from vger_subfields.ucladb_bib_subfield 
  where tag = '856z'
  and upper(subfield) like '%RESTRICTED TO UCLA LAW SCHOOL%'
)
-- Get broader set of CDL 856 fields, which we'll join to the UCLA ones later
, cdl_856 as (
  -- Starting set: All CDL 856 fields: 1140036 as of 20190610
  select record_id, field_seq 
  from vger_subfields.ucladb_bib_subfield 
  where tag = '856x'
  and subfield = 'CDL'
  -- Remove fields with 856 $3 containing "selected"
  minus
  select record_id, field_seq 
  from vger_subfields.ucladb_bib_subfield 
  where tag = '8563'
  and upper(subfield) like '%SELECTED%'
  -- Remove fields with 856 $z containing "No access to current"
  minus
  select record_id, field_seq 
  from vger_subfields.ucladb_bib_subfield 
  where tag = '856z'
  and upper(subfield) like '%NO ACCESS TO CURRENT%'
  -- Remove fields with 856 $3 containing "HathiTrust"
  minus
  select record_id, field_seq 
  from vger_subfields.ucladb_bib_subfield 
  where tag = '8563'
  and upper(subfield) like '%HATHITRUST%'
  -- Remove fields with 856 $x containing "UC open access"
  minus
  select record_id, field_seq 
  from vger_subfields.ucladb_bib_subfield 
  where tag = '856x' 
  and upper(subfield) like '%UC OPEN ACCESS%' 
  -- Remove fields with 856 $3 containing "not available online"
  minus
  select record_id, field_seq 
  from vger_subfields.ucladb_bib_subfield 
  where tag = '8563' 
  and upper(subfield) like '%NOT AVAILABLE ONLINE%' 
  -- Remove fields with 856 $3 not ending with '-': "this would exclude links for sources lacking access to current issues"
  minus
  select record_id, field_seq 
  from vger_subfields.ucladb_bib_subfield 
  where tag = '8563' 
  and subfield not like '%-'
)
select 
  ucla.record_id as bib_id
, po.po_number
, vger_support.unifix(bt.title_brief) as title_brief
, vger_subfields.GetFieldFromSubfields(ucla.record_id, ucla.field_seq) as f856
from ucla_856 ucla
-- Must be UCLA/CDL 856
inner join cdl_856 cdl on ucla.record_id = cdl.record_id -- and ucla.field_seq = cdl.field_seq
inner join ucladb.bib_text bt on ucla.record_id = bt.bib_id
inner join line_item li on ucla.record_id = li.bib_id
inner join purchase_order po on li.po_id = po.po_id
inner join po_status pos on po.po_status = pos.po_status
where pos.po_status_desc = 'Approved/Sent'
and po.normal_po_number not like 'CDL%'
order by ucla.record_id, ucla.field_seq
;

