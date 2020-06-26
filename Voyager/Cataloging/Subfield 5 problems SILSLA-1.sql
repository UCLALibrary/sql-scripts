/*  Records with $5 in certain fields, where the $5 is not an official CLU value.
    SILSLA-1
*/

select 
  record_id as bib_id
, substr(tag, 1, 3) as tag
, subfield as sfd5
, vger_subfields.getfieldfromsubfields(record_id, field_seq) as fld
from vger_subfields.ucladb_bib_subfield
where tag in ('6555', '7005', '7105', '7305', '7405')
and subfield not in (
  'CaLaRBC', 'CaLaUGAP', 'CaLaUCEA', 'CaLaUEM', 'CLU-FT', 'CLU', 'CLU-AR', 'CLU-ART', 'CLU-AUP', 'CLU-C', 'CLU-CHM', 'CLU-COL'
, 'CLU-CS', 'CLU-EMS', 'CLU-EP', 'CLU-GG', 'CLU-HAPI', 'CLU-L', 'CLU-M', 'CLU-MAP', 'CLU-MGT', 'CLU-MS', 'CLU-NC', 'CLU-P'
, 'CLU-PAS', 'CLU-REF', 'CLU-SC', 'CLU-TA', 'CLU-UA', 'CLU-UES', 'CLU-URL'
)
order by tag, sfd5, record_id
;
