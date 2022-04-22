#standardSQL
SELECT
*
FROM
ML.EXPLAIN_PREDICT(MODEL `dev-346101.msds_498_warehouse.simple_insurance_charges_model`,
  (
  SELECT
    *
  FROM
    `dev-346101.msds_498_warehouse.insurance_dev`
  WHERE
    charges IS NOT NULL),
  STRUCT(3 as top_k_features))
