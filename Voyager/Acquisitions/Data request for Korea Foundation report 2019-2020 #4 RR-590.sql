




select DISTINCT
  vger_support.unifix(bt.title) as title
, vger_subfields.Get880Field(bt.bib_id, '245') as title_880

, bt.bib_id
, ili.line_price/100 AS line_price


from ucla_fundledger_vw f

inner join invoice_line_item_funds ilif
  on f.ledger_id = ilif.ledger_id
  and f.fund_id = ilif.fund_id
inner join invoice_line_item ili on ilif.inv_line_item_id = ili.inv_line_item_id

inner join line_item li on ili.line_item_id = li.line_item_id
INNER JOIN PURCHASE_ORDER po ON li.po_id = po.po_id
inner join ucla_bibtext_vw bt on li.bib_id = bt.bib_id
inner join invoice i on ili.invoice_id = i.invoice_id
inner join invoice_status ist on i.invoice_status = ist.invoice_status
https://github.com/UCLALibrary/sql-scripts/commit/3f42bb9e22e3317d60d5b5a26cd275eb39c577d8
WHERE f.fund_code = 'C3MPEAKF-2'
                       AND (ili.update_date  >= to_date('20190101', 'YYYYMMDD') AND ili.update_date <= to_date('20190930', 'YYYYMMDD') )


      ORDER BY vger_support.unifix(bt.title) --bt.title

--'C3SPEAKF92' -- testing
--and ist.invoice_status_desc = 'Approved'
