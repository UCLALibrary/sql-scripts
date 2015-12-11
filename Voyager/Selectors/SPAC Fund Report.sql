-- Supporting tables, created daily by vger_rebuild_cataloging_reports
drop table vger_report.mfhd_spac_code purge;
create table vger_report.mfhd_spac_code as
select
  record_id as mfhd_id
, subfield as spac_code
from vger_subfields.ucladb_mfhd_subfield
where tag = '901a'
;
create index vger_report.ix_mfhd_spac_code on vger_report.mfhd_spac_code (spac_code, mfhd_id);
grant select on vger_report.mfhd_spac_code to ucla_preaddb;

/*  Find funds associated with purchase of materials with a given SPAC code.
    Relies on daily generation of table vger_report.mfhd_spac_code via vger_rebuild_cataloging_reports.
    Caveats:
    * Holdings have SPAC codes more consistently than bibs, and holdings are more consistently linked to purchase orders,
      so only SPACs in holdings are checked.
    * Materials purchased in bulk but cataloged separately will have holdings not linked to purchase orders.
    * Purchases not yet cataloged do not yet have SPAC codes.
    * Other cataloging practices (e.g., merging duplicate records) may also result in no link between SPAC holdings and purchase orders.
    * Purchases made before migration to Voyager have no fund data in Voyager.
    * Holdings not linked to purchase orders can't be linked to invoices.
    * Amounts shown are for the *copies* linked to holdings with SPACs.  Some purchases are for multiple copies, which 
      sometimes are not all on SPAC holdings.
      
    Jira: RR-135
    akohler 2015-12-11
*/
select
  m.spac_code
, m.mfhd_id
--, vger_support.unifix(bt.author) as author
, vger_support.unifix(bt.title) as title
, f.ledger_name
, f.fund_name
, f.fund_code
, ili.piece_identifier -- rarely used, more noise than value
, round( (ilif.percentage / 1000000), 2) as percentage
, ucladb.toBaseCurrency(ilif.amount, i.currency_code, i.conversion_rate) as usd_amount
, i.invoice_number
, ist.invoice_status_desc as invoice_status
, lis.line_item_status_desc as line_item_status
from vger_report.mfhd_spac_code m
inner join ucladb.bib_mfhd bm
  on m.mfhd_id = bm.mfhd_id
inner join ucladb.bib_text bt
  on bm.bib_id = bt.bib_id
-- Not all holdings are linked to acq data
left outer join ucladb.line_item_copy_status lics
  on m.mfhd_id = lics.mfhd_id
left outer join ucladb.line_item_status lis
  on lics.line_item_status = lis.line_item_status
left outer join ucladb.invoice_line_item_funds ilif
  on lics.copy_id = ilif.copy_id
left outer join ucladb.ucla_fundledger_vw f
  on ilif.ledger_id = f.ledger_id
  and ilif.fund_id = f.fund_id
left outer join ucladb.invoice_line_item ili
  on ilif.inv_line_item_id = ili.inv_line_item_id
left outer join ucladb.invoice i
  on ili.invoice_id = i.invoice_id
left outer join ucladb.invoice_status ist
  on i.invoice_status = ist.invoice_status
where m.spac_code = 'LIU1' -- parameter in Analyzer
order by m.mfhd_id
;

