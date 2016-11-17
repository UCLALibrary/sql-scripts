SELECT
  Upper(SubStr(o.last_name, 1, 1)) as sort_char
,	Trim(o.last_name || ', ' || o.first_name || ' ' || o.middle_initial) AS name
, o.operator_id
,	acqp.acq_profile_name
,	catp.cat_profile_name
,	circp.circ_profile_name
, gdcp.gdc_profile_name
,	mp.master_profile_name
FROM OPERATOR o
LEFT OUTER JOIN acq_operator acq ON o.operator_id = acq.operator_id
LEFT OUTER JOIN acq_profile acqp ON acq.acq_profile_id = acqp.acq_profile_id
LEFT OUTER JOIN cat_operator cat ON o.operator_id = cat.operator_id
LEFT OUTER JOIN cat_profile catp ON cat.cat_profile_id = catp.cat_profile_id
LEFT OUTER JOIN circ_operator circ ON o.operator_id = circ.operator_id
LEFT OUTER JOIN circ_profile circp ON circ.circ_profile_id = circp.circ_profile_id
left outer join gdc_operator gdc on o.operator_id = gdc.operator_id
left outer join gdc_profile gdcp on gdc.gdc_profile_id = gdcp.gdc_profile_id
LEFT OUTER JOIN master_operator m ON o.operator_id = m.operator_id
LEFT OUTER JOIN master_profile mp ON m.master_profile_id = mp.master_profile_id
-- filter out users with no login rights
WHERE Coalesce(acq_profile_name, cat_profile_name, circ_profile_name, gdc_profile_name, master_profile_name) IS NOT NULL
-- Filter out users who haven't logged in (or had account updated) in the last year)
-- Requires that vger_report.operator_audit table be kept up to date.....
and exists (
  select *
  from vger_report.operator_audit
  where operator_id = o.operator_id
)
ORDER BY sort_char, ucladb.norm2(name)
;

