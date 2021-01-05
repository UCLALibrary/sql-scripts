SELECT DISTINCT
   -- to_char(sysdate, 'MM/DD/YYYY') AS print_date,
    --ista.item_status_desc,
    --ista.item_status_type,
    bt.bib_id,
    i.item_id,
    iv.barcode AS item_barcode,
    vger_support.Unifix(bt.title) AS title,
    vger_support.Unifix(bt.author) AS author,
    iv.call_no || ' ' || iv.enumeration AS call_no,
  --  ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'x') AS f852x,
  --  ucladb.getmfhdsubfield(mm.mfhd_id, '852', 'z') AS f852z,
  --  ucladb.getallbibtag(bt.Bib_id, '901') AS f901,
    iv.perm_location,
  --  lt.location_name AS temp_location,
  --  vger_support.max_non_missing_status_date(i.item_id) AS other_status_date,
    is_m.item_status_date AS missing_date
   -- vger_support.get_all_item_status(i.item_id) AS all_statuses
FROM 
    ucladb.item i 
    inner join ucladb.bib_item bi ON i.item_id = bi.item_id
    inner join ucladb.bib_text bt ON bi.bib_id = bt.bib_id
    INNER JOIN BIB_MFHD bmf ON bt.BIB_ID = bmf.BIB_ID
    INNER JOIN MFHD_MASTER mm ON bmf.MFHD_ID = mm.MFHD_ID
    inner join ucladb.item_vw iv ON bi.item_id = iv.item_id 
    inner join ucladb.item_status is_m ON i.item_id = is_m.item_id
    --INNER JOIN ITEM_STATUS_TYPE ista ON is_m.ITEM_STATUS = ista.ITEM_STATUS_TYPE
    left outer join ucladb.location lt ON i.temp_location = lt.location_id 
    
WHERE iv.perm_location_code in ('sryr2', 'yrspald', 'yrspback', 'yrspbcbc', 'yrspcbc*', 'yrspbelt', 'yrspbelt*', 'yrspbooth', 'yrspboxm', 'yrspboxs', 'yrspbro', 'yrspcat', 'yrspcbc',
                           'yrspcbc*', 'yrspeip*', 'yrspeip**', 'yrspeip', 'yrspmin', 'yrspo*', 'yrspo**', 'yrspo***', 'yrsprpr', 'yrspstax', 'yrspvault', 'yrspbelt**',
                           'yrspbelt***', 'yrspinc', 'srar2', 'yrspsafe', 'muscrf', 'muscoblfac', 'arscrr', 'muscfacs', 'arsc', 'musctoc', 'muscsheet')

    and (is_m.item_status = 12 or is_m.item_status = 13 or is_m.item_status = 14)  
    and is_m.item_status_date between to_date('20200101', 'YYYYMMDD') AND to_date('20201231', 'YYYYMMDD')
    order by iv.perm_location--, bt.title 
    --iv.call_no
   
    
   
    
