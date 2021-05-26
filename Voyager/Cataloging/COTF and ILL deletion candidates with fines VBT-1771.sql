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
--where has_fine = 'Y'
;
-- 2921 bibs 2021-04-29 including ILL; 402 have fines with balances

-- Exports for Excel.  Uncomment the WITH start/end lines to get just unit totals.
--with x as (
select
  d.bib_id
, d.mfhd_id
, mi.item_id
, f.fine_fee_id
, d.loc
, d.title
, mi.item_enum
, f.create_date as fine_date
, ucladb.tobasecurrency(f.fine_fee_amount) as amount
, ucladb.tobasecurrency(f.fine_fee_balance) as balance
, f.fine_fee_note
, fft.fine_fee_desc
from vger_report.tmp_cotf_delete d
inner join ucladb.mfhd_item mi on d.mfhd_id = mi.mfhd_id
inner join ucladb.fine_fee f on mi.item_id = f.item_id
inner join ucladb.fine_fee_type fft on f.fine_fee_type = fft.fine_fee_type
where d.has_fine = 'Y'
and f.fine_fee_balance != 0
--and f.fine_fee_note is not null
order by f.create_date desc
--) select substr(loc, 1, 2) as unit, sum(amount) as amount, sum(balance) as balance from x group by substr(loc, 1, 2) order by unit
;

