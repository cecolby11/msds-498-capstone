SELECT * FROM
ML.PREDICT(MODEL `dev-346101.msds_498_warehouse.simple_insurance_charges_model`,
  (
  SELECT
    age,
    sex,
    bmi,
    children,
    smoker, 
    region,
    charges
  FROM
    `dev-346101.msds_498_warehouse.insurance_dev`
  WHERE
    charges IS NOT NULL)
  )
LIMIT 100
