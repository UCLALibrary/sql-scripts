with funds as (
  select
    ledger_id
  , fund_id
  , fund_code
  , case 
      when substr(fund_code, 3, 1) in ('D', 'S') then 'Serials'
      else 'Monos'
  end as fund_split
  , expenditures
  from ucla_fundledger_vw
  where fiscal_period_name = '2018-2019'
  and fund_category = 'Reporting'
) 
select fund_split, sum(expenditures) from funds group by fund_split
;
-- 2607 funds: 16455106.17
/*
Monos	5857618.62
Serials	10597487.55
*/

with funds as (
  select
    ledger_id
  , fund_id
  , fund_code
  , case 
      when substr(fund_code, 3, 1) in ('D', 'S') then 'Serials'
      else 'Monos'
  end as fund_split
  , expenditures
  from ucla_fundledger_vw
  where fiscal_period_name = '2018-2019'
  and fund_category = 'Reporting'
) 
select
  f.fund_split
, ucladb.setCurrencyDecimals(sum(ilif.amount), 'USD') as usd
from funds f
inner join invoice_line_item_funds ilif on f.ledger_id = ilif.ledger_id and f.fund_id = ilif.fund_id
group by f.fund_split
;
/*
Monos	5212306.4
Serials	10504041.12
*/

with locs as (
  select location_id
  from location
  where location_code in (
  'arbf**&***', 'arbtrf*', 'arcr', 'arplay', 'arrf', 'arrfcase3', 'arrfdsk', 'arrfelec', 'arrfidx', 'arrfover', 'arrs', 'arrse', 'arrsprscp', 'arscript', 'birf', 'birfdsk', 'birfhist', 'birs', 'birsayr', 'birsclas', 'birse', 'birsprscp', 'clcook', 'clenig', 'clgrfn', 'clnews', 'clnrfc', 'clperm', 'clrf', 'clrfatls', 'clrfbio', 'clrfcase', 'clrfdict', 'clrfdsk', 'clrfencyc', 'clrfidx', 'clrflitc', 'clrfnewidx', 'clrfwall', 'clrs', 'clrs1', 'clrs2', 'clrs3', 'clrse', 'clrsprscp', 'clsustain', 'cltrav', 'clvidgames', 'clzine', 'eadvd', 'earf', 'ears', 'idcoll', 'idstx', 'lwcivideo', 'lwphil', 'lwrf', 'lwrfdsk', 'lwrfsh', 'lwrs', 'lwrsper', 'lwtrr', 'mgciperm', 'mgcirfrs', 'mgcirs', 'mgrf', 'mgrfatlas', 'mgrfcdrom', 'mgrffiche', 'mgrfidx1', 'mgrfidx2', 'mgrfidx3', 'mgrfidx4', 'mgrfidx5', 'mgrfidx6', 'mgrfidx7', 'mgrfidx8', 'mgrfnews', 'mgrs', 'mgrse', 'mgrsprscp', 'mgrsstrg', 'murf', 'murs', 'murse', 'mursprscp', 'muscrf', 'scrf', 'scrfabst', 'scrfready', 'scrfspect', 'scrfstax', 'scrs', 'scrse', 'scrsprscp', 'sgcrs', 'sgrf', 'sgrfabst', 'sgrse', 'sgrsperm', 'sgrsprscp', 'smrf', 'smrfatls', 'smrfbiog', 'smrfconf', 'smrfcred', 'smrfcurr', 'smrfdict', 'smrfdsk', 'smrfjnldir', 'smrfwt', 'smrse', 'smrsperm', 'smrsprscp', 'uaref', 'yrcipr', 'yrelec', 'yrlcolres', 'yrlrefcol', 'yrrisalce', 'yrrisalcw', 'yrrisatl', 'yrrisbio', 'yrriscats', 'yrrisdcore', 'yrrisdctr', 'yrrisdsk', 'yrrisdstf', 'yrrisedu', 'yrrisedux', 'yrriselec', 'yrrisgrts', 'yrrislit', 'yrrismaps', 'yrrismi', 'yrrisnuc', 'yrrisrr', 'yrrisrrwt', 'yrrissr', 'yrristec', 'yrrs', 'yrrse', 'yrrsprscp'
  )
)
, funds as (
  select
    ledger_id
  , fund_id
  , fund_code
  , case 
      when substr(fund_code, 3, 1) in ('D', 'S') then 'Serials'
      else 'Monos'
  end as fund_split
  , expenditures
  from ucla_fundledger_vw
  where fiscal_period_name = '2018-2019'
  and fund_category = 'Reporting'
) 
select 
  ucladb.setCurrencyDecimals(sum(ilif.amount), 'USD') as usd
from funds f
inner join invoice_line_item_funds ilif on f.ledger_id = ilif.ledger_id and f.fund_id = ilif.fund_id
inner join line_item_copy_status lics on ilif.copy_id = lics.copy_id
-- Check final holdings loc, not expected loc from order
inner join mfhd_master mm on lics.mfhd_id = mm.mfhd_id
inner join locs l on mm.location_id = l.location_id
;
-- 216,661.74 with IJ to final mfhd
-- out of 15,711,804.88

set escape on;
select *
--sum(expenditures)
from ucla_fundledger_vw
where fiscal_period_name = '2018-2019'
and fund_category = 'Reporting'
and ledger_name = 'SALES \& SERVICES 18-19'
;