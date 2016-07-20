select DISTINCT
  ufa.ledger_name
, vger_support.get_fiscal_period(i.invoice_status_date) as fiscal_year
, ucladb.toBaseCurrency(li.line_price, i.currency_code, i.conversion_rate) AS committment

, po.po_number
, po.currency_code
, pon.note
, pos.po_status_desc
, lit.line_item_type_desc AS li_type
--, pon.print_note
--, li.line_price AS committment
, v.vendor_code
, f.fund_code

, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate) AS inv_amt --line_price
--, ili.piece_identifier
--, ucladb.getbibtag(bt.Bib_id, '022') AS f022
, bt.title as title
, bt.publisher
, ucladb.getbibtag(bt.Bib_id, '856') AS f856
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'b') AS f852b
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'h') AS f852h
--, pos.po_status_desc
--, lics.line_item_status

from ucladb.purchase_order po
left OUTER JOIN po_type pot ON po.po_type = pot.po_type
left OUTER  JOIN PO_NOTES pon ON po.PO_ID = pon.PO_ID

left outer join ucladb.vendor v on po.vendor_id = v.vendor_id
left outer join ucladb.po_status pos on po.po_status = pos.po_status
left outer join ucladb.line_item li on po.po_id = li.po_id
left outer join ucladb.line_item_copy_status lics on li.line_item_id = lics.line_item_id
left OUTER JOIN LINE_ITEM_TYPE lit ON li.LINE_ITEM_TYPE = lit.LINE_ITEM_TYPE
left outer join location l on lics.location_id = l.location_id
left outer join MFHD_MASTER mm ON l.LOCATION_ID = mm.LOCATION_ID
  AND lics.MFHD_ID = mm.MFHD_ID
left outer join ucladb.line_item_funds lif on lics.copy_id = lif.copy_id
left outer join ucla_fundledger_vw ufa ON lif.fund_id = ufa.fund_id AND lif.ledger_id = ufa.ledger_id
left outer join ucladb.fund f on lif.ledger_id = f.ledger_id and lif.fund_id = f.fund_id
left outer join ucladb.bib_text bt on li.bib_id = bt.bib_id
left outer join ucladb.invoice_line_item ili on li.line_item_id = ili.line_item_id
left outer join ucladb.invoice i on ili.invoice_id = i.invoice_id
left outer join ucladb.invoice_status ist on i.invoice_status = ist.invoice_status

   WHERE
  (
    ufa.ledger_name LIKE 'BIOMED%'
    --OR ufa.ledger_name LIKE 'Spec/Regental%')
    -- (ufa.ledger_name LIKE 'BIOMED%'  OR ufa.ledger_name LIKE 'Biomed%')

--Arts, AUL Collections, BioMed, College, CRIS, Law Differential, Management, Music, EAL, SEL, Spec/Foundation, Spec/Regental, Special Collections
  --FY: 08/09, 09/10, 10/11, 11/12, 12/13


 AND    pot.po_type_desc = 'Continuation'

and pos.po_status_desc in ('Approved/Sent', 'Received Complete', 'Received Partial')

AND  -- (vger_support.get_fiscal_period(i.invoice_status_date) = '2008-2009'
    --OR vger_support.get_fiscal_period(i.invoice_status_date) = '2009-2010'
    --OR
       (vger_support.get_fiscal_period(i.invoice_status_date) = '2013-2014'
    OR vger_support.get_fiscal_period(i.invoice_status_date) = '2014-2015'
    OR vger_support.get_fiscal_period(i.invoice_status_date) = '2015-2016')  )

    GROUP BY
      f.fund_code
, vger_support.unifix(nvl2(bt.author, bt.author || ' / ' || bt.title_brief, bt.title_brief))
, po.po_number
, v.vendor_code
, ucladb.toBaseCurrency(ili.line_price, i.currency_code, i.conversion_rate)
, ucladb.toBaseCurrency(li.line_price, i.currency_code, i.conversion_rate)
, vger_support.get_fiscal_period(i.invoice_status_date)
, ufa.ledger_name
, bt.Bib_id
, bt.title
, ili.piece_identifier
, pos.po_status_desc
, po.currency_code
, pon.note
, bt.publisher
, ucladb.getbibtag(bt.Bib_id, '856')
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'b')
, ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'h')
--, ili.piece_identifier
, lit.line_item_type_desc


--, pon.print_note

--, lics.line_item_status


    ORDER BY --vger_support.get_fiscal_period(i.invoice_status_date),
    bt.title
