select *
from patron p
where patron_id = 379013
;
select * from fine_fee where patron_id = 449817;
select * from fine_fee_transactions where fine_fee_id in (select fine_fee_id from fine_fee where patron_id = 449817);
select * from patron where patron_id in (379013, 449817);

with patrons as (
  select
    p.patron_id
  , p.current_charges
  , p.total_fees_due -- stand-in for Current Fees?
  , p.current_hold_shelf -- none during closure?
  , p.current_call_slips -- none during closure?
  , case when exists (
      select * from fine_fee_transactions 
      where fine_fee_id in (
        select fine_fee_id from fine_fee
        where patron_id = p.patron_id
      )
    )
    then 1
    else 0
  end as historical_fines
  , p.expire_date  from patron p
  where p.expire_date <= to_date('20190701', 'YYYYMMDD')
)
select 
  patron_id
from patrons
where (current_charges + total_fees_due + current_hold_shelf + current_call_slips + historical_fines) = 0
order by patron_id
;

-- Proxy patrons
select
  p1.last_name || ', ' || p1.first_name as p1_name
, pb1.patron_barcode as p1_barcode
, p1.expire_date as p1_expires
, p2.last_name || ', ' || p2.first_name as p2
, pb2.patron_barcode as p2_barcode
, p2.expire_date as p2_expires
from proxy_patron pp
inner join patron_barcode pb1 on pp.patron_barcode_id = pb1.patron_barcode_id
inner join patron p1 on pb1.patron_id = p1.patron_id
inner join patron_barcode pb2 on pp.patron_barcode_id_proxy = pb2.patron_barcode_id
inner join patron p2 on pb2.patron_id = p2.patron_id
;
