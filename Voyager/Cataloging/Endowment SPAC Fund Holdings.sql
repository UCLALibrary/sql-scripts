/*  Endowment funds which should have SPACs on bibs/holdings
    RR-283 / VBT-1303
*/
-- Import spac/fund data from Excel into vger_support.tmp_vbt1303_import

select * from vger_support.tmp_vbt1303_import;
select max(length(code)), max(length(f1)), max(length(f2)), max(length(f3)), max(length(f4)), max(length(f5)), max(length(f6)), max(length(f7)), max(length(f8)) from vger_support.tmp_vbt1303_import;

-- Clean up pesky trailing spaces
update vger_support.tmp_vbt1303_import set f1 = trim(f1) where length(f1) > 10;
commit;

-- Import data has 1-8 funds per SPAC; transform into relational data for real use.
-- Another temporary table, until we can translate these reporting fund codes into allocated fund codes.
create table vger_support.tmp_rpt_spac_fund_map (
  spac_code varchar2(10) not null
, fund_code varchar2(10) not null
)
;

insert into vger_support.tmp_rpt_spac_fund_map (spac_code, fund_code)
with d as (
  select code, f1 as fund from vger_support.tmp_vbt1303_import where f1 is not null
  union
  select code, f2 as fund from vger_support.tmp_vbt1303_import where f2 is not null
  union
  select code, f3 as fund from vger_support.tmp_vbt1303_import where f3 is not null
  union
  select code, f4 as fund from vger_support.tmp_vbt1303_import where f4 is not null
  union
  select code, f5 as fund from vger_support.tmp_vbt1303_import where f5 is not null
  union
  select code, f6 as fund from vger_support.tmp_vbt1303_import where f6 is not null
  union
  select code, f7 as fund from vger_support.tmp_vbt1303_import where f7 is not null
  union
  select code, f8 as fund from vger_support.tmp_vbt1303_import where f8 is not null
)
select distinct code, fund from d
;
commit;

-- Create the real. permanent table
create table vger_support.spac_fund_map (
  spac_code varchar2(10) not null
, fund_code varchar2(10) not null
)
;
create index vger_support.ix_spac_fund_map_fund on vger_support.spac_fund_map (fund_code, spac_code);
create index vger_support.ix_spac_fund_map_spac on vger_support.spac_fund_map (spac_code, fund_code);
grant select on vger_support.spac_fund_map to ucla_preaddb;

insert into vger_support.spac_fund_map
with fund_data as (
  select
    fund_code as reporting_code
  , fund_name as reporting_name
  , vger_support.GetAllocatedFundCode_ucla(ledger_id, fund_id) as allocated_code
  , fiscal_period_name
  , ledger_name
  from ucladb.ucla_fundledger_vw
  where fund_code in (select distinct fund_code from vger_support.tmp_rpt_spac_fund_map)
  and fiscal_period_name = vger_support.Get_Fiscal_Period(sysdate)
)
select distinct
  spac_code
, allocated_code
from vger_support.tmp_rpt_spac_fund_map fm
inner join fund_data fd on fm.fund_code = fd.reporting_code
;
commit;

-- Need to add allocated funds for these manually, as reporting fund codes have changed since initial project.
/*
select spac_code, f.ledger_name, f.fund_name, f.fund_code
from vger_support.tmp_rpt_spac_fund_map fm
left outer join ucladb.ucla_fundledger_vw f on fm.fund_code = f.fund_code
where spac_code in ('BEIM1', 'ENGBT', 'FIEMN', 'FLMBM', 'FUA', 'GRUNB', 'LTAUR', 'SMOTH')
and f.fiscal_period_name = '2017-2018'
order by spac_code
;
*/

insert into vger_support.spac_fund_map (spac_code, fund_code) values ('BEIM1', '2IS008');
insert into vger_support.spac_fund_map (spac_code, fund_code) values ('ENGBT', '2IS005');
insert into vger_support.spac_fund_map (spac_code, fund_code) values ('FIEMN', '2IS011');
insert into vger_support.spac_fund_map (spac_code, fund_code) values ('FLMBM', '2IS002');
insert into vger_support.spac_fund_map (spac_code, fund_code) values ('FUA', '2IS009');
insert into vger_support.spac_fund_map (spac_code, fund_code) values ('GRUNB', '2IS012');
insert into vger_support.spac_fund_map (spac_code, fund_code) values ('LTAUR', '4IS002');
insert into vger_support.spac_fund_map (spac_code, fund_code) values ('SMOTH', '2IS003');
commit;

-- Make sure there's at least one entry for every spac in the initial import
select *
from vger_support.spac_fund_map fm
where not exists (
  select *
  from vger_support.tmp_vbt1303_import
  where code = fm.spac_code
)
;
-- No rows, nothing missing

-- Drop initial import table and working table
drop table vger_support.tmp_vbt1303_import purge;
drop table vger_support.tmp_rpt_spac_fund_map purge;

select count(*) from vger_support.spac_fund_map;
-- 95 rows 20190603

-- SPACs and funds from the final map, with extra fund data for humans
with allocated as (
  select 
    fm.spac_code
  , sm.name as spac_name
  , fm.fund_code
  , f.fund_name
  , f.ledger_name
  , f.ledger_id
  , f.fund_id
  from vger_support.spac_fund_map fm
  inner join ucladb.ucla_fundledger_vw f
    on fm.fund_code = f.fund_code
    and f.fiscal_period_name = vger_support.Get_Fiscal_Period(sysdate)
  inner join vger_support.spac_map sm on fm.spac_code = sm.code
)
select 
  al.spac_code
, al.spac_name
, al.ledger_name
, al.fund_code
, al.fund_name
, rpt.fund_code as rpt_fund_code
, rpt.fund_name as rpt_fund_name
, rpt.institution_fund_id as fau
from allocated al
-- Get the child reporting funds
left outer join ucladb.ucla_fundledger_vw rpt
  on al.ledger_id = rpt.ledger_id
  and al.fund_id = rpt.parent_fund_id
order by al.spac_code, al.ledger_name, al.fund_code, rpt_fund_code
;


-- Funds associated with multiple SPACs?  2 pairs
select * from vger_support.spac_fund_map where fund_code in (
  select fund_code from vger_support.spac_fund_map group by fund_code having count(*) > 1
)
order by fund_code, spac_code;

-- Query for update via SpacAdder program
with d as (
  select
    s.spac_code
  , sm.name as spac_name
  , s.fund_code
  , fa.ledger_name
  , fa.fund_name as alloc_name
  , fa.fund_code as alloc_code
  , fr.fund_name as rpt_name
  , fr.fund_code as rpt_code
  , li.bib_id
  , case
      when exists (select * from vger_subfields.ucladb_bib_subfield where record_id = li.bib_id and tag = '901a' and subfield = s.spac_code)
      then 'Yes' 
      else null
    end as bib_spac_exists
  , lics.mfhd_id
  , case
      when exists (select * from vger_subfields.ucladb_mfhd_subfield where record_id = lics.mfhd_id and tag = '901a' and subfield = s.spac_code)
      then 'Yes' 
      else null
    end as mfhd_spac_exists
  from vger_support.spac_fund_map s
  -- Allocated fund
  inner join ucladb.ucla_fundledger_vw fa
    on s.fund_code = fa.fund_code
    -- ignore fiscal period, need to see across all FPs
  -- Reporting fund(s)
  inner join ucladb.ucla_fundledger_vw fr
    on fa.ledger_id = fr.ledger_id
    and fa.fund_id = fr.parent_fund_id
  inner join ucladb.invoice_line_item_funds ilif
    on fr.ledger_id = ilif.ledger_id
    and fr.fund_id = ilif.fund_id
  inner join ucladb.invoice_line_item ili 
    on ilif.inv_line_item_id = ili.inv_line_item_id
  inner join ucladb.line_item li 
    on ili.line_item_id = li.line_item_id
  inner join ucladb.line_item_copy_status lics
    on ilif.copy_id = lics.copy_id
  left outer join vger_support.spac_map sm
    on s.spac_code = sm.code
)
select distinct -- since invoice-based, and many POs have multiple invoices
  d.bib_id
, mfhd_id
, spac_code
, spac_name
from d
where ( bib_spac_exists is null or mfhd_spac_exists is null)
-- line_item_copy_status references some holdings which no longer exist at all...
and exists (
  select *
  from ucladb.mfhd_master
  where mfhd_id = d.mfhd_id
)
order by spac_code, bib_id, mfhd_id
;

