--also used for RR-323
SELECT DISTINCT
bt.bib_id,
bt.LANGUAGE,
(SELECT REPLACE(normal_heading, 'UCOCLC', '')
      FROM bib_index WHERE bib_id = bt.bib_id AND index_code = '0350' AND normal_heading LIKE 'UCOCLC%' AND ROWNUM < 2
  ) AS oclc_number,
ib.item_barcode,
bt.title,
mm.normalized_call_no,
mfhd_item.item_enum,
bt.pub_dates_combined,
--Max (cta.charge_date) AS last_charge_date,
--Max (cta.discharge_date) AS last_discharge_date,
--TO_CHAR (i.create_date,'FMMM/DD/YYYY') AS date_of_acq,
bt.pub_place,
--ucladb.getbibtag(bt.Bib_id, '650') AS f650
ucladb.getallbibtag(bt.bib_id, '650') AS f_subjects,
f.fund_code

            , case
    when exists (
        select *
        from bib_mfhd bm4
        inner join mfhd_master mm4 on bm4.mfhd_id = mm4.mfhd_id
        inner join location l4 on mm4.location_id = l4.location_id
        where bm4.bib_id = bt.bib_id
        and l4.location_code like 'sr%' --or like 'sr%', depending on your requirements
      ) then 'Y'
                else 'N'
end as has_srlf

, case
    when exists (
        select *
        from bib_mfhd bm5
        inner join mfhd_master mm5 on bm5.mfhd_id = mm5.mfhd_id
        inner join location l5 on mm5.location_id = l5.location_id
        where bm5.bib_id = bt.bib_id
        and l5.location_code not in ('sr', 'yr', 'yr*', 'yr**', 'yr***')

      ) then 'Y'
                else 'N'
end as has_other_ucla



FROM ucla_bibtext_vw bt

--bt
INNER JOIN BIB_MFHD ON bt.BIB_ID = BIB_MFHD.BIB_ID
INNER JOIN MFHD_MASTER  mm
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID ON BIB_MFHD.MFHD_ID = mm.MFHD_ID
INNER JOIN ITEM  i
 INNER JOIN ITEM_BARCODE ib ON i.ITEM_ID = ib.ITEM_ID
INNER JOIN MFHD_ITEM ON i.ITEM_ID = MFHD_ITEM.ITEM_ID ON mm.MFHD_ID = MFHD_ITEM.MFHD_ID
left OUTER JOIN circ_trans_archive cta ON i.item_id = cta.item_id

left outer join LINE_ITEM li ON bt.BIB_ID = li.BIB_ID
left outer join LINE_ITEM_COPY_STATUS lics ON li.LINE_ITEM_ID = lics.LINE_ITEM_ID
left outer join LINE_ITEM_FUNDS lif ON lics.COPY_ID = lif.COPY_ID
left outer join FUND f ON lif.FUND_ID = f.FUND_ID

--left OUTER JOIN CIRCCHARGES_VW cc ON mm.MFHD_ID = cc.MFHD_ID

            WHERE bt.bib_format = 'am'
              AND bt.LANGUAGE <> 'eng'
              AND l.location_code IN ('yr', 'yr*', 'yr**', 'yr***')
              AND normalized_call_no between vger_support.NormalizeCallNumber('P') and vger_support.NormalizeCallNumber('R1')

-- Either (1) or (2) must be true:
-- (1) has other holdings, or (2) only other Voyager holdings are suppressed or are Internet
AND     (
         EXISTS
                -- (1) has other holdings
                (       SELECT *
                        from bib_mfhd bm2
                        inner join mfhd_master mm2 on bm2.mfhd_id = mm2.mfhd_id
                        inner join location l2 on mm2.location_id = l2.location_id
                        where bm2.bib_id = bt.bib_id
                        and mm2.mfhd_id != mm.mfhd_id -- DIFFERENT MFHD
                )
         OR  EXISTS
                -- (2) Other mfhds are either suppressed or Internet
                (       select *
                        from bib_mfhd bm3
                        inner join mfhd_master mm3 on bm3.mfhd_id = mm3.mfhd_id
                        inner join location l3 on mm3.location_id = l3.location_id
                        where bm3.bib_id = bt.bib_id
                        and mm3.mfhd_id != mm.mfhd_id -- DIFFERENT MFHD
                        AND (mm3.suppress_in_opac = 'N' OR l3.location_code != 'in')
                )

            )
             AND NOT EXISTS
         (select * from circcharges_vw where item_id = i.item_id
                     and charge_date_only < to_date('20050101', 'YYYYMMDD') )  -- equals zero chargeouts before 2005
                --     and charge_date_only > to_date('20031231', 'YYYYMMDD') )  -- equals zero chargeouts after 2003

                   
          -- AND NOT EXISTS (SELECT * FROM circcharges_vw WHERE mfhd_id = mm.mfhd_id)

group BY
bt.bib_id,
network_number,
ib.item_barcode,
bt.pub_place,
bt.title,
--mm.display_call_no,
mm.normalized_call_no,
ucladb.getbibtag(bt.Bib_id, '300'),
--ucladb.getbibtag(bt.Bib_id, '490'),

bt.author,
--bt.TITLE,
ucladb.getbibtag(bt.Bib_id, '650'),
bt.LANGUAGE,
f.fund_code,
bt.pub_dates_combined,
mfhd_item.item_enum



ORDER BY mm.normalized_call_no



