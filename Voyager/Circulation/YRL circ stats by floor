
SELECT DISTINCT
Count (cc.charge_date_only) AS CHARGES,
bt.title,
cc.renewal_count,
mm.normalized_call_no,
mm.mfhd_id,
bt.bib_id




FROM CIRCCHARGES_VW cc
INNER JOIN BIB_TEXT bt ON cc.BIB_ID = bt.BIB_ID
INNER JOIN MFHD_MASTER mm ON cc.MFHD_ID = mm.MFHD_ID
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID


  WHERE  l.location_code = 'yr'
  and charge_date_only BETWEEN  to_date('20140701', 'YYYYMMDD') AND to_date('20150630', 'YYYYMMDD')

                     AND normalized_call_no between vger_support.NormalizeCallNumber('PA') and vger_support.NormalizeCallNumber('Z')


                     GROUP BY
                      bt.title,
                      cc.renewal_count,
                      bt.bib_id,
                      mm.mfhd_id,
                      mm.normalized_call_no

                     ORDER BY mm.normalized_call_no

