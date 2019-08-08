 SELECT  DISTINCT
b.bib_id,
b.title,
b.author,
mm.normalized_call_no,
--b.begin_pub_date,
b.pub_dates_combined,
--b.publisher_date,
b.publisher,
l.location_name,
--mfhd_master.update_date,
TO_CHAR(mm.update_date,'fmMM/ DD/ YYYY') AS mm_up_DATE,
TO_CHAR(li.update_date,'fmMM/ DD/ YYYY') AS li_up_DATE



 FROM ucla_bibtext_vw b

INNER JOIN BIB_MFHD bbf ON b.BIB_ID = bbf.bib_id
INNER JOIN MFHD_MASTER mm ON bbf.mfhd_id = mm.mfhd_id
INNER JOIN LOCATION l ON mm.LOCATION_ID = l.LOCATION_ID --ON bbf.MFHD_ID = mm.MFHD_ID
inner join line_item li ON b.bib_id = li.bib_id
inner join purchase_order po ON li.po_id = po.po_id


WHERE    (b.publisher LIKE '%Academic Cell%'
       OR b.publisher LIKE '%Academic Press%'
       OR b.publisher LIKE '%AOCS Press%'
       OR b.publisher LIKE '%Amirsys%'
       OR b.publisher LIKE '%Balliere % Tindall%'
       OR b.publisher LIKE '%Butterworth % Heinemann%'
       OR b.publisher LIKE '%Cell Press%'
       OR b.publisher LIKE '%CIMA Publishing%'
       OR b.publisher LIKE '%Chandos Publishing%'
       OR b.publisher LIKE '%Churchill Livingstone%'
       OR b.publisher LIKE '%Current Opinion%'
       OR b.publisher LIKE '%Elsevier%'
       OR b.publisher LIKE '%Elsevier Masson%'
       OR b.publisher LIKE '%Gulf Professional Publishing%'
       OR b.publisher LIKE '%Hanley and Belfus Medical Publishers%'
       OR b.publisher LIKE '%Morgan Kaufman%'
       OR b.publisher LIKE '%Mosby%'
       OR b.publisher LIKE '%Newnes%'
       OR b.publisher LIKE '%Saunders%'
       OR b.publisher LIKE '%Security Executive Council%'
       OR b.publisher LIKE '%Syngress%'
       OR b.publisher LIKE '%William Andrew%'
       OR b.publisher LIKE '%Woodhead Publishing%')

                    --  and b.begin_pub_date between '2007' AND '2016'
                      AND li.update_date BETWEEN to_date('20070101', 'YYYYMMDD') AND to_date('20161231', 'YYYYMMDD')
                         --b.publisher_date,

      AND l.location_name IN ('Bio Circ Desk All YR Res',
                                      'Bio Circ Desk Class',
                                      'Bio Circ Desk Perm Res',
                                      'Bio Ref',
                                      'Bio Reserves',
                                      'Bio Stacks',
                                      'Bio Stacks Over*',
                                      'Bio Stacks Over**',
                                      'SEL Chem Book Stacks',
                                      'SEL Chem NBS',
                                      'SEL Chem Ready Ref',
                                      'SEL Chem Ref Stacks',
                                      'SEL GG Stacks',
                                      'SEL GG NBS',
                                      'SEL GG Ref',
                                      'SEL EMS Stacks',
                                      'SEL EMS Ref',
                                      'SEL EMS NBS')


ORDER BY l.location_name,
 mm.normalized_call_no
