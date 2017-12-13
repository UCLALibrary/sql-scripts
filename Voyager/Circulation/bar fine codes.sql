SELECT
  cpg.circ_group_name,
  fft.fine_fee_desc,
  cbs.subcode
FROM
  vger_support.cb_subcodes cbs
  INNER JOIN ucladb.fine_fee_type fft ON cbs.fine_fee_type = fft.fine_fee_type
  INNER JOIN ucladb.circ_policy_group cpg ON cbs.circ_group_id = cpg.circ_group_id
