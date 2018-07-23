/*  Photographic related items purchased by Library Special Collections FY08/09-17/18
    RR-378
*/

-- Limit to Purchase Orders with either +YRL Special Collections in the "Ship to/Bill to" fields or *YRL SpecColl Acq in the "Site" field.
with lsc_pos as (
  select *
  from purchase_order
  -- hard-coded for simplicity: specific location values in 3 different fields
  where order_location = 553 -- yrscacq	*YRL SpecColl Acq
  or ship_location = 593 -- yrlspc	+YRL Special Collections
  or bill_location = 593 -- yrlspc	+YRL Special Collections
) 
select 
  po.po_number
, i.invoice_number
, i.invoice_status_date as date_paid
, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) as usd_line_price
, li.bib_id
, vger_support.unifix(bt.title) as title
from lsc_pos po
inner join line_item li on po.po_id = li.po_id
inner join invoice_line_item ili on li.line_item_id = ili.line_item_id
inner join invoice i on ili.invoice_id = i.invoice_id
inner join bib_text bt on li.bib_id = bt.bib_id
where i.invoice_status = 1 -- Approved
and i.invoice_status_date between to_date('20080701', 'YYYYMMDD') and to_date('20180630 235959', 'YYYYMMDD HH24MISS') -- FY 2008/2009 thru 2017/2018
and exists (
  select *
  from vger_subfields.ucladb_bib_subfield
  where record_id = li.bib_id
  and (tag like '245%' or tag like '5%') -- 245, 5xx
  and lower(subfield) like '%photographic%'
)
order by i.invoice_status_date
;


