SELECT * FROM
ML.EVALUATE(
  MODEL `dev-346101.msds_498_warehouse.simple_insurance_charges_model`, # Model name
  # Table to evaluate against
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
    charges IS NOT NULL
  )
)
