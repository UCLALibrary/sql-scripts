SELECT DISTINCT
Count (*) AS CHARGES,
cc.patron_group_name,
bt.bib_id,
--item.create_date AS CREATE_date,
mm.normalized_call_no,
--cc.patron_group_name,
bt.TITLE,
bt.author,
bt.pub_place,
bt.publisher,
bt.begin_pub_date AS pub_date


FROM ucla_bibtext_vw bt


left outer join BIB_MFHD ON bt.BIB_ID = BIB_MFHD.BIB_ID
left outer join MFHD_MASTER  mm
left outer join LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID ON BIB_MFHD.MFHD_ID = mm.MFHD_ID
left outer join CIRCCHARGES_VW cc ON mm.MFHD_ID = cc.MFHD_ID

            WHERE l.location_code = 'clnrfc'  --Powell RFC
                 AND cc.patron_group_name = 'UCLA Undergrad'

          
bt.bib_id,
--item.create_date AS CREATE_date,
mm.normalized_call_no,
cc.patron_group_name,
bt.TITLE,
bt.author,
bt.pub_place,
bt.publisher,
bt.begin_pub_date --AS pub_date




ORDER BY  mm.normalized_call_no
