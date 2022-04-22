# Provide name of model
CREATE OR REPLACE MODEL `dev-346101.msds_498_warehouse.simple_insurance_charges_model`
# Specify options
OPTIONS
  (model_type='linear_reg',
    input_label_cols=['charges'],
    enable_global_explain=TRUE) AS
# Provide training data
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
  charges IS NOT NULL # Filter for rows containing data we want to predict. 
