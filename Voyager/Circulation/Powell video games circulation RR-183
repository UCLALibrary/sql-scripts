SELECT   DISTINCT
 	i.historical_charges AS charges,
  --, TO_CHAR(i.invoice_date,'FMMM/DD/YYYY')  last_inv_date
  TO_CHAR (i.create_date,'FMMM/DD/YYYY') AS date_of_acq,
	--vger_support.unifix(bt.author) AS author,
	vger_support.unifix(bt.title) AS title,
  ucladb.getbibtag(bt.Bib_id, '650') AS f650,
	--bt.publisher,
	--bt.pub_place,
	--bt.publisher_date,
    --                 bt.publisher || ' ' || bt.pub_place || ' ' || bt.publisher_date AS pub_data,
	mm.normalized_call_no
  --bt.bib_id

--	i.historical_browses
--,vger_support.renewals_from_date(i.item_id,to_date(#prompt('DATE1')#, 'YYYY-MM-DD')) AS renewal_count
FROM
	ucladb.item i
	inner join ucladb.bib_item bi on i.item_id = bi.item_id
	inner join ucladb.ucla_bibtext_vw bt on bi.bib_id = bt.bib_id
	inner join ucladb.mfhd_item mi on i.item_id= mi.item_id
	inner join ucladb.mfhd_master mm on mi.mfhd_id = mm.mfhd_id
WHERE
	i.perm_location = 753   --l.location_code = 'clvidgames'

                    AND (i.historical_charges = 0 OR i.historical_charges != 0)

                    ORDER BY vger_support.unifix(bt.title)

