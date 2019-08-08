WITH charges_discharges AS
(
    SELECT 
--        to_char(cta.charge_date,   'YYYY-MM') AS MONTH,
        decode(cta.patron_group_id,   0,   'No Group',   report_group_desc) AS group_name,
        --  pg.patron_group_name as patron_group_name,
        cpg.circ_group_name AS location,
        count(distinct cta.patron_id) as completed_charge_patrons,
        0 as completed_renew_patrons,
        0 as open_charge_patrons,
        0 as open_renew_patrons
    FROM 
        ucladb.circ_trans_archive cta 
        LEFT OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = cta.patron_group_id 
        LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
        LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id 
        LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON cta.charge_location = cpl.location_id 
        LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
        LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON cta.circ_transaction_id = rst.circ_transaction_id AND cta.item_id = rst.item_id
    WHERE 
        cta.charge_date BETWEEN vger_support.LWS_UTILITY.PREV_FISCAL_YR_START(SYSDATE)
        AND ADD_MONTHS(vger_support.LWS_UTILITY.PREV_FISCAL_YR_START(SYSDATE), 12)
    group by
--        to_char(cta.charge_date,   'YYYY-MM'),
        decode(cta.patron_group_id,   0,   'No Group',   report_group_desc),
        --  pg.patron_group_name as patron_group_name,
        cpg.circ_group_name 

    UNION ALL

    -- CIRC_TRANS_ARCHIVE for Renewals
    SELECT 
--        to_char(rta.renew_date,   'YYYY-MM') AS MONTH,
        decode(cta.patron_group_id,   0,   'No Group',   report_group_desc) AS group_name,
        --  pg.patron_group_name as patron_group_name,
        cpg.circ_group_name AS location,
        0 as completed_charge_patrons,
        count(distinct cta.patron_id) as completed_renew_patrons,
        0 as open_charge_patrons,
        0 as open_renew_patrons
    FROM 
        ucladb.circ_trans_archive cta 
        LEFT OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = cta.patron_group_id 
        LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
        LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id
        INNER JOIN ucladb.renew_trans_archive rta ON cta.circ_transaction_id = rta.circ_transaction_id 
        LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON rta.renew_location = cpl.location_id 
        LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
        LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON cta.circ_transaction_id = rst.circ_transaction_id AND cta.item_id = rst.item_id
    WHERE 
        rta.renew_date BETWEEN vger_support.LWS_UTILITY.PREV_FISCAL_YR_START(SYSDATE)
        AND ADD_MONTHS(vger_support.LWS_UTILITY.PREV_FISCAL_YR_START(SYSDATE), 12)
        AND vger_support.lws_csc.is_staff_renewal(rta.renew_oper_id) = 1
    group by
--        to_char(rta.renew_date,   'YYYY-MM'),
        decode(cta.patron_group_id,   0,   'No Group',   report_group_desc),
        --  pg.patron_group_name as patron_group_name,
        cpg.circ_group_name 

    UNION ALL

    -- CIRC_TRANSACTIONS for Chargeouts
    SELECT 
--        to_char(ct.charge_date,   'YYYY-MM') AS MONTH,
        decode(ct.patron_group_id,   0,   'No Group',   report_group_desc) AS group_name,
        --  pg.patron_group_name as patron_group_name,
        cpg.circ_group_name AS location,
        0 as completed_charge_patrons,
        0 as completed_renew_patrons,
        count(distinct ct.patron_id) as open_charge_patrons,
        0 as open_renew_patrons
    FROM 
        ucladb.circ_transactions ct 
        LEFT OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = ct.patron_group_id 
        LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
        LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id 
        LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON ct.charge_location = cpl.location_id 
        LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
        LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON ct.circ_transaction_id = rst.circ_transaction_id AND ct.item_id = rst.item_id
    WHERE 
        ct.charge_date BETWEEN vger_support.LWS_UTILITY.PREV_FISCAL_YR_START(SYSDATE)
        AND ADD_MONTHS(vger_support.LWS_UTILITY.PREV_FISCAL_YR_START(SYSDATE), 12)
    group by
--        to_char(ct.charge_date,   'YYYY-MM'),
        decode(ct.patron_group_id,   0,   'No Group',   report_group_desc),
        --  pg.patron_group_name as patron_group_name,
        cpg.circ_group_name 

    UNION ALL

    -- CIRC_TRANSACTIONS for Renewals
    SELECT 
--        to_char(rt.renew_date,   'YYYY-MM') AS MONTH,
        decode(ct.patron_group_id,   0,   'No Group',   report_group_desc) AS group_name,
        --  pg.patron_group_name as patron_group_name,
        cpg.circ_group_name AS location,
        0 as completed_charge_patrons,
        0 as completed_renew_patrons,
        0 as open_charge_patrons,
        count(distinct ct.patron_id) as open_renew_patrons
    FROM 
        ucladb.circ_transactions ct 
        LEFT OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = ct.patron_group_id 
        LEFT OUTER JOIN vger_support.csc_patron_group_map pgm ON pg.patron_group_id = pgm.patron_group_id 
        LEFT OUTER JOIN vger_support.csc_report_group rg ON pgm.report_group_id = rg.report_group_id
        INNER JOIN ucladb.renew_transactions rt ON ct.circ_transaction_id = rt.circ_transaction_id 
        LEFT OUTER JOIN ucladb.circ_policy_locs cpl ON rt.renew_location = cpl.location_id 
        LEFT OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
        LEFT OUTER JOIN vger_report.ucladb_reserve_trans rst ON ct.circ_transaction_id = rst.circ_transaction_id AND ct.item_id = rst.item_id
    WHERE 
        rt.renew_date BETWEEN vger_support.LWS_UTILITY.PREV_FISCAL_YR_START(SYSDATE)
        AND ADD_MONTHS(vger_support.LWS_UTILITY.PREV_FISCAL_YR_START(SYSDATE), 12)
        AND vger_support.lws_csc.is_staff_renewal(rt.renew_oper_id) = 1
    group by
--        to_char(rt.renew_date,   'YYYY-MM'),
        decode(ct.patron_group_id,   0,   'No Group',   report_group_desc),
        --  pg.patron_group_name as patron_group_name,
        cpg.circ_group_name 
)
SELECT 
    location,
    group_name,
    sum(completed_charge_patrons) as completed_charge_patrons,
    sum(completed_renew_patrons) as completed_renew_patrons,
    sum(open_charge_patrons) as open_charge_patrons,
    sum(open_renew_patrons) as open_renew_patrons
FROM 
    charges_discharges
GROUP BY 
    location,
    group_name
ORDER BY 
    location,
    group_name
