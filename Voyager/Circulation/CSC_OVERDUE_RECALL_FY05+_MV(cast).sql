
REM VGER_REPORT CSC_OVERDUE_RECALL_FY05+_MV

  CREATE MATERIALIZED VIEW "VGER_REPORT"."CSC_OVERDUE_RECALL_FY05+_MV"
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "VGER_REPORT" 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH COMPLETE ON DEMAND
  WITH ROWID USING DEFAULT LOCAL ROLLBACK SEGMENT
  DISABLE QUERY REWRITE
  AS SELECT 
-- CIRC_TRANS_ARCHIVE for Overdue
to_char(cta.overdue_notice_date,   'YYYY-MM') AS
MONTH,
  cpg.circ_group_name AS location,
  decode(cta.circ_transaction_id,   NULL,   cast(0 as number(38,0)),   decode(cta.overdue_notice_date,   NULL,   cast(0 as number(38,0)),   1)) AS
overdue,
  cast(0 as number(38,0)) AS recall,
  cast(0 as number(38,0)) AS over_recall
FROM ucladb.circ_trans_archive cta LEFT
OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = cta.patron_group_id LEFT
OUTER JOIN ucladb.circ_policy_locs cpl ON cta.charge_location = cpl.location_id LEFT
OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id 
WHERE cta.overdue_notice_date BETWEEN to_date('2005-07-01',   'YYYY-MM-DD')
 AND trunc(add_months(last_day(sysdate)+1, -1)) -- First day of the month regardless of when called.

UNION ALL

-- CIRC_TRANS_ARCHIVE for Recall
SELECT to_char(cta.recall_date,   'YYYY-MM') AS
MONTH,
  cpg.circ_group_name AS location,
  cast(0 as number(38,0)) AS overdue,
  decode(cta.circ_transaction_id,   NULL,   cast(0 as number(38,0)),   decode(cta.recall_date,   NULL,   cast(0 as number(38,0)),   1)) AS
recall,
  cast(0 as number(38,0)) AS over_recall
FROM ucladb.circ_trans_archive cta LEFT
OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = cta.patron_group_id
INNER JOIN ucladb.circ_policy_locs cpl ON cta.charge_location = cpl.location_id
INNER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id
WHERE cta.recall_date BETWEEN to_date('2005-07-01',   'YYYY-MM-DD')
 AND trunc(add_months(last_day(sysdate)+1, -1)) -- First day of the month regardless of when called.

UNION ALL

-- CIRC_TRANS_ARCHIVE for Overdue Recall
SELECT to_char(cta.over_recall_notice_date,   'YYYY-MM') AS
MONTH,
  cpg.circ_group_name AS location,
  cast(0 as number(38,0)) AS overdue,
  cast(0 as number(38,0)) AS recall,
  decode(cta.circ_transaction_id,   NULL,   cast(0 as number(38,0)),   decode(cta.over_recall_notice_date,   NULL,   cast(0 as number(38,0)),   1)) AS
over_recall
FROM ucladb.circ_trans_archive cta LEFT
OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = cta.patron_group_id
INNER JOIN ucladb.circ_policy_locs cpl ON cta.charge_location = cpl.location_id
INNER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id
WHERE cta.over_recall_notice_date BETWEEN to_date('2005-07-01',   'YYYY-MM-DD')
 AND trunc(add_months(last_day(sysdate)+1, -1)) -- First day of the month regardless of when called.

UNION ALL

-- CIRC_TRANSACTIONS for Overdue
SELECT to_char(ct.overdue_notice_date,   'YYYY-MM') AS
MONTH,
  cpg.circ_group_name AS location,
  decode(ct.circ_transaction_id,   NULL,   cast(0 as number(38,0)),   decode(ct.overdue_notice_date,   NULL,   cast(0 as number(38,0)),   1)) AS
overdue,
  cast(0 as number(38,0)) AS recall,
  cast(0 as number(38,0)) AS over_recall
FROM ucladb.circ_transactions ct LEFT
OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = ct.patron_group_id
INNER JOIN ucladb.circ_policy_locs cpl ON ct.charge_location = cpl.location_id
INNER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id
WHERE ct.overdue_notice_date BETWEEN to_date('2005-07-01',   'YYYY-MM-DD')
 AND trunc(add_months(last_day(sysdate)+1, -1)) -- First day of the month regardless of when called.

UNION ALL

-- CIRC_TRANSACTIONS for Recall
SELECT to_char(ct.recall_date,   'YYYY-MM') AS
MONTH,
  cpg.circ_group_name AS location,
  cast(0 as number(38,0)) AS overdue,
  decode(ct.circ_transaction_id,   NULL,   cast(0 as number(38,0)),   decode(ct.recall_date,   NULL,   cast(0 as number(38,0)),   1)) AS
recall,
  cast(0 as number(38,0)) AS over_recall
FROM ucladb.circ_transactions ct LEFT
OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = ct.patron_group_id
INNER JOIN ucladb.circ_policy_locs cpl ON ct.charge_location = cpl.location_id
INNER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id
WHERE ct.recall_date BETWEEN to_date('2005-07-01',   'YYYY-MM-DD')
 AND trunc(add_months(last_day(sysdate)+1, -1)) -- First day of the month regardless of when called.

UNION ALL

-- CIRC_TRANSACTIONS for Overdue Recall
SELECT to_char(ct.over_recall_notice_date,   'YYYY-MM') AS
MONTH,
  cpg.circ_group_name AS location,
  cast(0 as number(38,0)) AS overdue,
  cast(0 as number(38,0)) AS recall,
  decode(ct.circ_transaction_id,   NULL,   cast(0 as number(38,0)),   decode(ct.over_recall_notice_date,   NULL,   cast(0 as number(38,0)),   1)) AS
over_recall
FROM ucladb.circ_transactions ct LEFT
OUTER JOIN ucladb.patron_group pg ON pg.patron_group_id = ct.patron_group_id
INNER JOIN ucladb.circ_policy_locs cpl ON ct.charge_location = cpl.location_id
INNER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id
WHERE ct.over_recall_notice_date BETWEEN to_date('2005-07-01',   'YYYY-MM-DD')
 AND trunc(add_months(last_day(sysdate)+1, -1)) -- First day of the month regardless of when called.
;
 
REM VGER_REPORT CSC_OVERDUE_RECALL_FY05+_MV

   COMMENT ON TABLE "VGER_REPORT"."CSC_OVERDUE_RECALL_FY05+_MV"  IS 'snapshot table for snapshot VGER_REPORT.CSC_OVERDUE_RECALL_FY05+_MV';
 