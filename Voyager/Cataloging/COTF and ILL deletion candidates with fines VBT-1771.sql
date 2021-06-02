/*  Various queries for COTF/ILL records which should be deleted, but can't be because of unpaid fines.
    VBT-1771
*/

-- Working table
drop table vger_report.tmp_cotf_delete purge;
create table vger_report.tmp_cotf_delete as
select 
  bm.bib_id
, bm.mfhd_id
-- Other fields for review / cleanup
, (select location_code from ucladb.location where location_id  = (select location_id from ucladb.mfhd_master where mfhd_id = bm.mfhd_id)) as loc
, vger_support.unifix(bt.title) as title
, case
    when exists (select * from ucladb.line_item where bib_id = bm.bib_id)
    then 'Y'
  end as has_PO
, case
    when exists (select * from ucladb.circ_transactions where item_id in (select item_id from ucladb.mfhd_item where mfhd_id = bm.mfhd_id))
    then 'Y'
  end as charged_out
, case
    when exists (select * from ucladb.fine_fee where item_id in (select item_id from ucladb.mfhd_item where mfhd_id = bm.mfhd_id) and fine_fee_balance != 0)
    then 'Y'
  end as has_fine
, case
    when exists (select * from ucladb.reserve_list_items where item_id in (select item_id from ucladb.mfhd_item where mfhd_id = bm.mfhd_id))
    then 'Y'
  end as on_p_reserve
, case
    when exists (select * from ucladb.reserve_list_eitems where eitem_id in (select eitem_id from ucladb.eitem where mfhd_id = bm.mfhd_id))
    then 'Y'
  end as on_e_reserve
from ucladb.bib_history bh
inner join ucladb.location l1 on bh.location_id = l1.location_id and bh.action_type_id = 1 --Created
inner join ucladb.bib_mfhd bm on bh.bib_id = bm.bib_id
inner join ucladb.mfhd_history mh on bm.mfhd_id = mh.mfhd_id and mh.action_type_id = 1 --Created
inner join ucladb.location l2 on mh.location_id = l2.location_id
inner join ucladb.bib_text bt on bh.bib_id = bt.bib_id
where l1.location_code like '%loan%'
and l2.location_code like '%loan%'
and upper(bt.title_brief) not like '%CHROMEBOOK%'
/*  Skip the ILL exclusion for this project
-- No ILL holdings on this bib
and not exists (
  select * from ucladb.bib_location bl
  inner join ucladb.location l3 on bl.location_id = l3.location_id
  where bl.bib_id = bh.bib_id
  and l3.location_code like '%ill' 
  and l3.location_name like '%ILL'
)
*/
-- No 948 in this bib
and not exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = bh.bib_id
  and tag like '948%'
)
-- Not currently checked out
and not exists (
  select * from ucladb.circ_transactions
  where item_id in (select item_id from ucladb.bib_item where bib_id = bh.bib_id)
)
-- Has only one holdings record
and not exists (
  select bib_id from ucladb.bib_mfhd
  where bib_id = bh.bib_id
  group by bib_id
  having count(*) > 1
)
-- Does not have a 910 $a other than MARS
and not exists (
  select * from vger_subfields.ucladb_bib_subfield
  where record_id = bh.bib_id
  and tag = '910a'
  and subfield not like '%MARS%'
)
order by bm.bib_id
;

-- Stats
select count(*), count(distinct bib_id) from vger_report.tmp_cotf_delete
where has_fine = 'Y'
;
-- 2911 bibs 2021-05-26 including ILL; 387 have fines with balances

-- Exports for Excel.  Uncomment the WITH start/end lines to get just unit totals.
--with x as (
select
  d.bib_id
, d.mfhd_id
, mi.item_id
, ib.item_barcode
, d.loc
, d.title
, mi.item_enum
, f.create_date as fine_date
, f.fine_fee_note
, fft.fine_fee_desc
, f.patron_id
--, ucladb.tobasecurrency(f.fine_fee_amount) as amount 
, ucladb.tobasecurrency(f.fine_fee_balance) as balance -- This is the one we care about for waiving
, 2 as transaction_type -- Forgive
, 0 as transaction_method -- Undefined but valid per DR
, f.fine_fee_id
from vger_report.tmp_cotf_delete d
inner join ucladb.mfhd_item mi on d.mfhd_id = mi.mfhd_id
inner join ucladb.fine_fee f on mi.item_id = f.item_id
inner join ucladb.fine_fee_type fft on f.fine_fee_type = fft.fine_fee_type
left outer join ucladb.item_barcode ib on mi.item_id = ib.item_id and ib.barcode_status = 1 --Active
where d.has_fine = 'Y'
and f.fine_fee_balance != 0
--and f.fine_fee_balance != f.fine_fee_amount
--and f.fine_fee_note is not null
order by f.create_date desc
--) select substr(loc, 1, 2) as unit, sum(balance) as balance from x group by substr(loc, 1, 2) order by unit
;

-- Query for vger_addfeepost script
with d as (
  select
    f.patron_id
  , ucladb.tobasecurrency(f.fine_fee_balance) as balance -- This is the one we care about for waiving
  , 2 as transaction_type -- Forgive
  , 0 as transaction_method -- Undefined but valid per DR
  , f.fine_fee_id
  , 'Waived for Alma migration cleanup per VBT-1711' as fine_fee_note
  --, fft.fine_fee_desc
  from vger_report.tmp_cotf_delete d
  inner join ucladb.mfhd_item mi on d.mfhd_id = mi.mfhd_id
  inner join ucladb.fine_fee f on mi.item_id = f.item_id
  inner join ucladb.fine_fee_type fft on f.fine_fee_type = fft.fine_fee_type
  where d.has_fine = 'Y'
  and f.fine_fee_balance != 0
)
select
  patron_id || chr(9) ||
  balance || chr(9) ||
  transaction_type || chr(9) ||
  transaction_method || chr(9) ||
  fine_fee_id || chr(9) ||
  fine_fee_note
  as line
from d
order by fine_fee_id
;

-- Fines have been waived; these should get deleted by DeleteCOTF.exe tomorrow, check then
select * from tmp_cotf_delete 
where has_fine = 'Y'
and has_po is null
and charged_out is null
and on_p_reserve is null
and on_e_reserve is null
order by bib_id
;

-- What are these?
select 
  bt.title
, bm.bib_id
, bm.mfhd_id
, mi.item_id
, (select charge_date from circ_transactions where item_id = mi.item_id) as charge_date
--, ff.*
from ucladb.bib_text bt
inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
left outer join ucladb.mfhd_item mi on bm.mfhd_id = mi.mfhd_id
left outer join ucladb.fine_fee ff on mi.item_id = ff.item_id
where bt.title like '%Circulation %ecord%'
--and ff.fine_fee_balance != 0
order by mi.item_id, fine_fee_id
;



with d as (
  select
    f.patron_id
  , ucladb.tobasecurrency(f.fine_fee_balance) as balance -- This is the one we care about for waiving
  , 2 as transaction_type -- Forgive
  , 0 as transaction_method -- Undefined but valid per DR
  , f.fine_fee_id
  , 'Waived for Alma migration cleanup per VBT-1711' as fine_fee_note
  --, fft.fine_fee_desc
  from ucladb.bib_text bt
  inner join ucladb.bib_mfhd bm on bt.bib_id = bm.bib_id
  inner join ucladb.mfhd_item mi on bm.mfhd_id = mi.mfhd_id
  inner join ucladb.fine_fee f on mi.item_id = f.item_id
  inner join ucladb.fine_fee_type fft on f.fine_fee_type = fft.fine_fee_type
  where bt.title like 'Circulation record%'
  and f.fine_fee_balance != 0
)
select
  patron_id || chr(9) ||
  balance || chr(9) ||
  transaction_type || chr(9) ||
  transaction_method || chr(9) ||
  fine_fee_id || chr(9) ||
  fine_fee_note
  as line
from d
order by fine_fee_id
;


select bib_id, title
from ucladb.bib_text
where title like 'Law %irculation %ecord%'
order by bib_id
;

select item_barcode
from ucladb.item_barcode
where item_id in (36530,36531,3279123,5845900,5845916,5846346,5846525,5847322,5847621,5847648,5076277,5076278,5076421,5076566,5076736,6651310,6673387,6674020,6706126,6717934,6731830,6960613,6960659,6960671,6960677,6960406,6959601,6959603)
;

-- Naughty........
delete
from circ_trans_exception
where item_id in (36530,36531,3279123,5845900,5845916,5846346,5846525,5847322,5847621,5847648,5076277,5076278,5076421,5076566,5076736,6651310,6673387,6674020,6706126,6717934,6731830,6960613,6960659,6960671,6960677,6960406,6959601,6959603)
and trans_except_oper_id = 'akohler'
;
commit;

select * from circ_trans_exception;