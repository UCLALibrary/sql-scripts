
REM VGER_REPORT CSC_FINES_FY05+_MV

  CREATE MATERIALIZED VIEW "VGER_REPORT"."CSC_FINES_FY05+_MV"
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "VGER_REPORT" 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH COMPLETE ON DEMAND
  WITH ROWID USING DEFAULT LOCAL ROLLBACK SEGMENT
  DISABLE QUERY REWRITE
  AS SELECT cpg.circ_group_name AS location,
  -- The following tries to create a concept of an item-transaction
to_char(ff.patron_id) || '-' || to_char(ff.item_id) || '-' || to_char(ff.orig_charge_date,   'YYYY-MM') || '-' || to_char(ff.due_date,   'YYYY-MM') AS
item,
-- fine_fee_type of 1 is Overdue, 2 is Lost Item Replacement
-- trans_type of 1 is Payment, 2 is Forgive, and 3 is Error (which is ignored)
-- 
-- $overdue_payment = decode(ff.fine_fee_type,   1,   decode(fft.trans_type,   1,   1,   0),   0)
-- $overdue_forgive = decode(ff.fine_fee_type,   1,   decode(fft.trans_type,   2,   1,   0),   0)
-- $lost_payment = decode(ff.fine_fee_type,   2,   decode(fft.trans_type,   1,   1,   0),   0)
-- $lost_forgive = decode(ff.fine_fee_type,   2,   decode(fft.trans_type,   2,   1,   0),   0)
-- 
-- We want to sum payments and forgives individually, and also sum the total transactions.
-- This ensures only one transaction-item is counted even though an individual 
-- transaction may be a payment and a forgive.
-- 
-- decode(SUM($overdue_payment),   0,   decode(SUM($overdue_forgive),   0,   0,   1),   1) AS overdue,
-- SUM($overdue_payment) AS overdue_payment,
-- SUM($overdue_forgive) AS overdue_forgive,
-- decode(SUM($lost_payment),   0,      decode(SUM($lost_forgive),      0,   0,   1),   1) AS lost_item_replacement,
-- SUM($lost_payment) AS lost_item_replacement_payment,
-- SUM($lost_forgive) AS lost_item_replacement_forgive
  cast(vger_support.lws_utility.count_only_one(SUM(vger_support.lws_csc.overdue_payment(ff.fine_fee_type, fft.trans_type)), SUM(vger_support.lws_csc.overdue_forgive(ff.fine_fee_type, fft.trans_type))) as NUMBER(38,0)) AS overdue,
  SUM(cast(vger_support.lws_csc.overdue_payment(ff.fine_fee_type, fft.trans_type) as NUMBER(38,0))) AS overdue_payment,
  SUM(vger_support.lws_csc.overdue_forgive(ff.fine_fee_type, fft.trans_type)) AS overdue_forgive,
  cast(vger_support.lws_utility.count_only_one(SUM(vger_support.lws_csc.lost_payment(ff.fine_fee_type, fft.trans_type)), SUM(vger_support.lws_csc.lost_forgive(ff.fine_fee_type, fft.trans_type))) as NUMBER(38,0)) AS lost_item_replacement,
  SUM(vger_support.lws_csc.lost_payment(ff.fine_fee_type, fft.trans_type)) AS lost_item_replacement_payment,
  SUM(vger_support.lws_csc.lost_forgive(ff.fine_fee_type, fft.trans_type)) AS lost_item_replacement_forgive
FROM ucladb.fine_fee ff LEFT
OUTER JOIN ucladb.fine_fee_type fftp ON ff.fine_fee_type = fftp.fine_fee_type LEFT
OUTER JOIN ucladb.fine_fee_transactions fft ON ff.fine_fee_id = fft.fine_fee_id LEFT
OUTER JOIN ucladb.item i ON ff.item_id = i.item_id LEFT
OUTER JOIN ucladb.circ_policy_locs cpl ON i.perm_location = cpl.location_id LEFT
OUTER JOIN ucladb.circ_policy_group cpg ON cpl.circ_group_id = cpg.circ_group_id LEFT
OUTER JOIN ucladb.fine_fee_trans_type fftt ON fft.trans_type = fftt.transaction_type LEFT
OUTER JOIN ucladb.fine_fee_trans_method fftm ON fft.trans_method = fftm.method_type
WHERE trans_date BETWEEN to_date('2005-07-01',   'YYYY-MM-DD')
 AND trunc(add_months(last_day(sysdate)+1, -1)) -- First day of the month regardless of when called.
 AND transaction_type <> 3
GROUP BY cpg.circ_group_name,
  to_char(ff.patron_id) || '-' || to_char(ff.item_id) || '-' || to_char(ff.orig_charge_date,   'YYYY-MM') || '-' || to_char(ff.due_date,   'YYYY-MM')
;
 
REM VGER_REPORT CSC_FINES_FY05+_MV

   COMMENT ON TABLE "VGER_REPORT"."CSC_FINES_FY05+_MV"  IS 'snapshot table for snapshot VGER_REPORT.CSC_FINES_FY05+_MV';
 