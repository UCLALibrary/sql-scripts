/*  Law 856 fields (per 856 $x at least) which lack correct $u (missing URL or no protocol in URL)
    VBT-1008
*/
select 
  bsx.record_id as bib_id
, (select vger_support.unifix(title_brief) from bib_text where bib_id = bsx.record_id) as title_brief
, vger_subfields.GetFieldFromSubfields(bsx.record_id, bsx.field_seq) as f856
from vger_subfields.ucladb_bib_subfield bsx
where bsx.tag = '856x'
and bsx.subfield like '%UCLA Law%'
and (
    not exists (
      select *
      from vger_subfields.ucladb_bib_subfield
      where record_id = bsx.record_id
      and field_seq = bsx.field_seq
      and tag = '856u'
    )
    or exists (
      select *
      from vger_subfields.ucladb_bib_subfield
      where record_id = bsx.record_id
      and field_seq = bsx.field_seq
      and tag = '856u'
      and lower(subfield) not like 'http%'
    )
)
;