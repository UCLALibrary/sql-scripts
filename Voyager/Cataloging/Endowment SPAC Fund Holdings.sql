/*  Endowment funds which should have SPACs on bibs/holdings
    RR-283
*/
-- Import spac/fund data from Excel

-- Clean up pesky trailing spaces
update vger_report.tmp_rr283_import set f1 = trim(f1) where length(f1) > 10;
commit;

-- Import data has 1-8 funds per SPAC; transform into relational data for analysis
create table vger_report.tmp_rr283_funds as
with d as (
  select spac, f1 as fund from vger_report.tmp_rr283_import where f1 is not null
  union
  select spac, f2 as fund from vger_report.tmp_rr283_import where f2 is not null
  union
  select spac, f3 as fund from vger_report.tmp_rr283_import where f3 is not null
  union
  select spac, f4 as fund from vger_report.tmp_rr283_import where f4 is not null
  union
  select spac, f5 as fund from vger_report.tmp_rr283_import where f5 is not null
  union
  select spac, f6 as fund from vger_report.tmp_rr283_import where f6 is not null
  union
  select spac, f7 as fund from vger_report.tmp_rr283_import where f7 is not null
  union
  select spac, f8 as fund from vger_report.tmp_rr283_import where f8 is not null
)
select spac, fund from d
;
create index vger_report.ix_tmp_rr283_funds on vger_report.tmp_rr283_funds (fund, spac);

-- Drop initial import table
drop table vger_report.tmp_rr283_import purge;

select count(*) from vger_report.tmp_rr283_funds;
-- 182 rows
-- 1 dup removed for: BIOM2	F3DEBIANN1
-- stats...
select spac, count(*) as num from vger_report.tmp_rr283_funds group by spac order by num desc;
-- stats...
select count(distinct fund) from vger_report.tmp_rr283_funds;
-- stats...
select fund, count(*) from vger_report.tmp_rr283_funds group by fund having count(*) > 1;
-- stats...
select * from vger_report.tmp_rr283_funds where fund in (
  select fund from vger_report.tmp_rr283_funds group by fund having count(*) > 1
)
order by fund, spac;


-- Compare to Voyager ledger/po/invoice/holdings/bib data......

with d as (
  select
    s.spac
  , s.fund as fund_code
  , f.ledger_name
  , f.fund_name
  , li.bib_id
  , case
      when exists (select * from vger_subfields.ucladb_bib_subfield where record_id = li.bib_id and tag = '901a' and subfield = s.spac)
      then 'Yes' 
      else null
    end as bib_spac_exists
  , lics.mfhd_id
  , case
      when exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = lics.mfhd_id and tag = '901a' and subfield = s.spac)
      then 'Yes' 
      else null
    end as mfhd_spac_exists
  from vger_report.tmp_rr283_funds s
  -- Verified all fund codes provided via Excel still exist...
  inner join ucladb.ucla_fundledger_vw f
    on s.fund = f.fund_code
    -- ignore fiscal period, need to see across all FPs
  --  and f.fiscal_period_name = '2017-2018'
  inner join ucladb.invoice_line_item_funds ilif
    on f.ledger_id = ilif.ledger_id
    and f.fund_id = ilif.fund_id
  inner join ucladb.invoice_line_item ili 
    on ilif.inv_line_item_id = ili.inv_line_item_id
  inner join ucladb.line_item li 
    on ili.line_item_id = li.line_item_id
  inner join ucladb.line_item_copy_status lics
    on ilif.copy_id = lics.copy_id
  -- TESTING
  -- JOPAGE 11, KPM1 24, ABUNT 34
  --where s.spac = 'ABUNT' 
--order by s.spac, s.fund, li.bib_id, lics.mfhd_id
)
/* Quick query to list funds not matched to Voyager invoices
select distinct fund from vger_report.tmp_rr283_funds
minus
select distinct fund_code from d
order by 1;
*/
/*
-- Secondary query showing % of each fund/spac which has been done correctly
, interim as (
  select
    fund_code
  , spac
  , (select count(*) from d where spac = d2.spac and fund_code = d2.fund_code and bib_spac_exists is not null and mfhd_spac_exists is not null) as done
  , (select count(*) from d where spac = d2.spac and fund_code = d2.fund_code and (bib_spac_exists is null or mfhd_spac_exists is null)) as not_done
  from d d2
  group by fund_code, spac
)
select
  interim.*
, case 
    when not_done + done = 0 then 100
    else trunc( (done * 100 / (not_done + done) ), 0) -- round to nearest whole number
  end as pct_done
from interim
order by fund_code, spac
;
*/
-- Data reported, listing records needing SPACs added to bibs/mfhds or both
-- 12251 rows as of 2017-07-10
select distinct -- since invoice-based, and many POs have multiple invoices
  fund_code
, fund_name
, spac
, bib_id
, mfhd_id
from d
where bib_spac_exists is null
or mfhd_spac_exists is null
order by fund_code, spac, bib_id, mfhd_id
;






-- Cleanup
--drop table vger_report.tmp_rr283_funds purge;
