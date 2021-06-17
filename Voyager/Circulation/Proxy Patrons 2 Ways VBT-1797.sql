/*  Find proxy patrons, both real and the pseudo-patron UCLA way.
    VBT-1797
*/

-- 120 distinct patrons have total_fees_due, so get fine details for them
-- patron_id 242113 has two active groups
-- 1119 rows for reporting with fine details
select 
  p.patron_id
, p.last_name
, p.first_name
, p.middle_name
, p.title
, p.institution_id
, p.current_charges
, ucladb.tobasecurrency(p.total_fees_due) as total_fees_due
, fft.fine_fee_desc
, ib.item_barcode
, ucladb.tobasecurrency(ff.fine_fee_amount) as ff_amount
, ucladb.tobasecurrency(ff.fine_fee_balance) as ff_balance
, ff.orig_charge_date
, ff.fine_fee_note
, pb.patron_barcode
, pg.patron_group_name
, ( select listagg(note, ' *** ') within group (order by patron_note_id)
    from patron_notes
    where patron_id = p.patron_id
) as patron_notes
from patron p
left outer join patron_barcode pb on p.patron_id = pb.patron_id and pb.barcode_status = 1 --Active
left outer join patron_group pg on pb.patron_group_id = pg.patron_group_id
left outer join fine_fee ff on p.patron_id = ff.patron_id
left outer join fine_fee_type fft on ff.fine_fee_type = fft.fine_fee_type
left outer join item_barcode ib on ff.item_id = ib.item_id and ib.barcode_status = 1 --Active
where ( 
     p.normal_first_name like '%PROXY%'
  or p.normal_last_name like '%PROXY%'
  or p.normal_middle_name like '%PROXY%'
  or upper(p.title) like '%PROXY%'
  or upper(pg.patron_group_name) like '%PROXY%'
  or exists (select * from patron_notes where patron_id = p.patron_id and upper(note) like '%PROXY%')
)
and p.total_fees_due <> 0
and ff.fine_fee_balance <> 0
order by p.patron_id
;

-- The 466 others have no fines due so just basic info
select 
  p.patron_id
, p.last_name
, p.first_name
, p.middle_name
, p.title
, p.institution_id
, p.current_charges
, ucladb.tobasecurrency(p.total_fees_due) as total_fees_due
, pb.patron_barcode
, pg.patron_group_name
, ( select listagg(note, ' *** ') within group (order by patron_note_id)
    from patron_notes
    where patron_id = p.patron_id
) as notes
from patron p
left outer join patron_barcode pb on p.patron_id = pb.patron_id and pb.barcode_status = 1
left outer join patron_group pg on pb.patron_group_id = pg.patron_group_id
where ( 
     p.normal_first_name like '%PROXY%'
  or p.normal_last_name like '%PROXY%'
  or p.normal_middle_name like '%PROXY%'
  or upper(p.title) like '%PROXY%'
  or upper(pg.patron_group_name) like '%PROXY%'
  or exists (select * from patron_notes where patron_id = p.patron_id and upper(note) like '%PROXY%')
)
and p.total_fees_due = 0
order by p.patron_id
;







-- Real proxies = just 2
select 
  p1.last_name as p1_last_name
, p1.first_name as p1_first_name
, p1.institution_id as p1_institution_id
, pb1.patron_barcode as p1_patron_barcode
, (select barcode_status_desc from patron_barcode_status where barcode_status_type = pb1.barcode_status) as p1_barcode_status
, p1.total_fees_due as p1_total_fees_due
, p2.last_name as p2_last_name
, p2.first_name as p2_first_name
, p2.institution_id as p2_institution_id
, pb2.patron_barcode as p2_patron_barcode
, (select barcode_status_desc from patron_barcode_status where barcode_status_type = pb2.barcode_status) as p2_barcode_status
, p2.total_fees_due as p2_total_fees_due
from proxy_patron pp
inner join patron_barcode pb1 on pp.patron_barcode_id = pb1.patron_barcode_id
inner join patron p1 on pb1.patron_id = p1.patron_id
inner join patron_barcode pb2 on pp.patron_barcode_id_proxy = pb2.patron_barcode_id
inner join patron p2 on pb2.patron_id = p2.patron_id
;

