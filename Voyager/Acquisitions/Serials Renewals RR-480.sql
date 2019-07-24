/*  Serials renewals omnibus
    RR-480
*/

with po_data as (
  select
    po.po_number
  , pos.po_status_desc
  , pot.po_type_desc
  , v.vendor_code
  , v.vendor_name
  , va.account_number
  , lis1.line_item_status_desc as po_line_status
  , case lis2.line_item_status_desc when 'Pending' then null else lis2.line_item_status_desc end as inv_line_status
  , lit.line_item_type_desc
  , li.quantity as po_quantity
  , ucladb.toBaseCurrency(li.line_price, po.currency_code, po.conversion_rate) as po_usd_price
  , l.location_name
  , pon.note as po_notes
  , lin.note as line_item_notes
  , li.line_item_id
  , li.bib_id
  , vger_support.unifix(bt.title_brief) as title_brief
  , bt.place_code
  --, vger_support.unifix(bt.publisher) as publisher
  , ( select subfield 
      from vger_subfields.ucladb_bib_subfield 
      where record_id = li.bib_id 
      and tag in ('260b', '264b') 
      and field_seq = ( 
        select max(field_seq) 
        from vger_subfields.ucladb_bib_subfield 
        where record_id = li.bib_id 
        and tag in ('260b', '264b')
      )
      and rownum < 2
  ) as publisher
  , bt.edition
  , bt.end_pub_date
  , bt.isbn
  , bt.issn
  , (select subfield from vger_subfields.ucladb_bib_subfield where record_id = li.bib_id and tag = '830a' and rownum < 2) as series
  , mm.display_call_no
  , ucladb.getAllBibTag(li.bib_id, '856', 2) as all_856s
  from purchase_order po
  inner join po_status pos on po.po_status = pos.po_status
  inner join po_type pot on po.po_type = pot.po_type
  inner join vendor v on po.vendor_id = v.vendor_id
  inner join line_item li on po.po_id = li.po_id
  inner join line_item_type lit on li.line_item_type = lit.line_item_type
  inner join line_item_copy_status lics on li.line_item_id = lics.line_item_id
  inner join location l on lics.location_id = l.location_id
  inner join line_item_status lis1 on lics.line_item_status = lis1.line_item_status
  inner join line_item_status lis2 on lics.invoice_item_status = lis2.line_item_status
  inner join bib_text bt on li.bib_id = bt.bib_id
    -- Optional
  left outer join mfhd_master mm on lics.mfhd_id = mm.mfhd_id -- a few copies aren't linked to holdings....
  left outer join po_notes pon on po.po_id = pon.po_id
  left outer join line_item_notes lin on li.line_item_id = lin.line_item_id
  left outer join vendor_account va on po.account_id = va.account_id
  where pos.po_status_desc in ('Approved/Sent', 'Received Partial')
  and pot.po_type_desc = 'Continuation'
  and lit.line_item_type_desc in ('Membership', 'Multi-part', 'Standing Order', 'Subscription')
  and v.vendor_code not in ('EBSCOFR', 'BEB', 'EBS', 'EPJ', 'HAR')
)
, invoice_data as (
  select 
    ili.line_item_id
  , ili.inv_line_item_id
  , ili.invoice_id
  , ili.unit_price
  , ili.line_price
  , ili.quantity
  , ili.piece_identifier
  , row_number() over (partition by ili.line_item_id order by ili.update_date desc) rn
  from invoice_line_item ili
  where ili.line_item_id in (select distinct line_item_id from po_data)
)
, latest_inv_data as (
  select
    inv.line_item_id
  , inv.piece_identifier
  , inv.quantity as inv_quantity
  , ucladb.toBaseCurrency(inv.line_price, i.currency_code, i.conversion_rate) as usd_price
  , to_char(i.invoice_date, 'YYYY-MM-DD') as invoice_date
  , f.ledger_name
  , f.fund_code
  , f.fund_name
  from invoice_data inv
  inner join invoice i on inv.invoice_id = i.invoice_id
  inner join invoice_line_item_funds ilif on inv.inv_line_item_id = ilif.inv_line_item_id
  inner join ucla_fundledger_vw f on ilif.ledger_id = f.ledger_id and ilif.fund_id = f.fund_id
  where rn = 1 -- "latest", since we sorted by descending invoice line update date above
)
--select count(*) from po_data union all select count(*) from latest_inv_data;  -- 10475 po, 7780 latest inv as of 2019-07-23
select
  pod.*
, invd.invoice_date
, invd.piece_identifier
, invd.usd_price
, invd.inv_quantity
, invd.ledger_name
, invd.fund_name
, invd.fund_code
from po_data pod
left outer join latest_inv_data invd on pod.line_item_id = invd.line_item_id
order by pod.po_number
;
-- 10659 rows combined 2019-07-23
