# msds-498-capstone

![Infra Actions Status](https://github.com/cecolby11/msds-498-capstone/actions/workflows/build_infra.yml/badge.svg)
![Hello World API Actions Status](https://github.com/cecolby11/msds-498-capstone/actions/workflows/deploy_gae_insurance.yml/badge.svg)

## Project Overview

This project predicts medical charges from personal data such as age, smoker status, bmi, etc. using linear regression. 

This could be useful for healthcare companies to forecast costs and assess premiums, or to provide patients greater insight into the most important factors influencing their charges and into their potential charges when planning HSA contributions. 

### Architecture

The project is hosted in Google Cloud. The main features are: 
- A "Producer" Cloud Function consumes data updates and publishes them to cloud storage or a pubsub topic 
- BigQuery tables serve as the "Data Warehouse" 
- Batch ETL: A Dataflow job consumes data from Cloud Storage Bucket, transforms it, and loads it to BigQuery warehouse
- Streaming ETL: A Dataflow job consumes data from PubSub Topic, transforms it, and loads it to BigQuery warehouse
- BigQuery ML queries create a linear regression model to predict insurance charges from the data. Additional BigQuery ML queries generate batch predictions from the model and save to BigQuery. 
- The resulting BigQuery Model is exported to cloud storage in Tensorflow SavedModel format. An AI Platform Prediction model is created from the exported model for online prediction. 
- A Python app deployed to Google App Engine hosts a simple UI and calls the AI Platform model to consume online predictions.

For the Dataflow ETLs, initially google-provided templates were used and the jobs were configured via the GCP console. I also experimented with creating my own flex template for the streaming job and running it via the CLI. See the `streaming_beam` directory and its README for the commands for this. 

![Architecture Diagram](./MSDS-498-architecture.png?raw=true "Architecture Diagram")

### Directory Structure
```
gae_py_insurance              # App Code for consuming AI Platform online predictions (Python/Flask, deployed to GAE).
│   main.py                   # App entry point, Flask app definition - GAE python runtime expects this to be named main
│   predict.py                # AI Platform library implementation and business logic for the prediction
│   templates/                # HTML dynamic templates served by Flask routes for simple UI 
│   requirements.txt          # Lists dependencies required for the production python application
│   app.yaml                  # Configuration for web service deployment to App Engine
└───.gcloudignore             # Lists files in the enclosing directory that should not be deployed to App Engine 
.github/workflows/            # GitHub Actions configuration files for CICD
│   build_infra_dev.yaml      # GHA workflow configuration to build application infrastructure (Terraform IaC files)
└───deploy_gae_insurance.yaml # GHA workflow configuration to deploy Python app to GAE
iac/                          # Terraform Infrastructure-as-Code configuration files
│   <env>/                    # Per-environment Terraform variables, outputs, and state configuration
└───modules/                  # Terraform modules, used by all environments
src_producer_Fxn/             # Node.js application code for the "Producer" Cloud Function to Ingest data into GCP from an endpoint and publish it to cloud storage or pubsub topic. 
streaming_beam/               # Experimental code for creating a Dataflow flex template for a Streaming pipeline
.gitignore                    # Lists files that should not be tracked in source control
.terraform-version            # Configures terraform version for tfenv utility to install
.editorconfig                 # Configuration for code editors
```

### Data
The open dataset I am working with is `Medical Cost Personal Datasets` available on Kaggle: https://www.kaggle.com/datasets/mirichoi0218/insurance  

### Deployment
Deploying to Google Cloud is automated with GitHub Actions. 

There are two workflows defined in GitHub Actions: 
- One to provision the GCP infrastructure from the terraform IaC files. This pipeline runs when changes are made to the IaC directory or the ETL source code directories.
- One to deploy the application code for the python UI for consuming online predictions to Google App Engine. This pipeline runs when changes are made to the gae_py_insurance directory.

The project currently has one environment: dev. The dev environment is deployed when changes are pushed to the `dev` branch in GitHub. The deployment pipelines are already configured to deploy a prod environment when changes are pushed to a `main` branch in GitHub once a prod GCP project is set up and a `prod` IAC directory configured. 

You can also manually deploy any of the workflows from the 'Actions' tab in the GitHub repository. 

## Setting up a new environment in GCP[^1]
- Within the `iac` directory, duplicate an existing terraform environment directory and rename it for your environment. 
- Create a new project in the GCP console for the new environment. Add the project ID to the `iac/{env}/variables.tf` in the `iac/{env}` directory. [^2]
- Per project: Via the GCP storage console, create a new private storage bucket for your account terraform state files. Update the bucket name in `iac/{env}/state.tf`. 
- Per project: Create a new `terraform` service account for Terraform via the GCP IAM console before running commands. Give it the following roles:

  | Role | Purpose | 
  | --- | --- | 
  | Project Owner [^3] | To provision a new App Engine application. |
  | Storage Object Admin | To create and update remote statefile - object creator is enough to create a statefile but isn't sufficient to obtain the terraform lockfile, changing to object admin resolves the issue. |
  | Roles Administrator | To create other IAM Roles | 
  | Storage Object Viewer | Needed only if you need to run `terraform init -migrate-state`. |
  | Storage Admin | To create storage buckets. |
  | BigQuery User | To create datasets. |
  | PubSub Admin | To manage pub sub topics and subscriptions. |
  | Cloud Functions Admin | To manage cloud functions. |
  | Cloud Scheduler Admin | To manage cloud scheduler jobs. |
  | Service Account Admin | To create and manage service accounts. |
  | Security Admin | To set the service account on the cloud function |
  | Service Account User | To act as the service account to set the service account on the cloud function |
  | AI Platform Admin | To create new AI Platform model resource | 
- Per project: Enable the necessary APIs in the console [^4]
  - Identity and Access Management (IAM) API
  - Cloud Storage API
  - Dataflow API (to create Dataflow Jobs)
  - Data Pipelines API (to create a Dataflow Data Pipeline)
  - Cloud Scheduler API (to create a Dataflow Data Pipeline)
  - PubSub API
  - Cloud Functions API
  - Cloud Scheduler API
  - Cloud Build API (so terraform can tell whether the cloud function has completed provisioning)
  - AI Platform Models API 
  - App Engine Admin API

### Setting up CICD Permissions and Workflows
- Create a new job in each CICD workflow .yml in the `.github/workflows` directory specific to the new environment 
- Via the service accounts section of the GCP IAM console, create a new JSON key on the `terraform` service account in your environment and download it. Add the key to the GitHub repository secrets for use in CICD (e.g. name it GCLOUD_KEY_DEV in the secrets and refer to it as that in actions pipelines)
- Run the Infra CICD pipeline to provision the infrastructure.

### Terraforming Locally
Navigate to the 'service accounts' section of the GCP IAM console. Create a new JSON key for the `terraform` service account and download the JSON key to your local machine from GCP.

Set the credentials: set the path to the key by setting the CLI GOOGLE_APPLICATION_CREDENTIALS variable with the path to the json key file on your machine. This enables you to run the terraform the same way the GitHub Actions workflow would, from your command line. 
```bash
# set the path to the key using the cli's export GOOGLE_APPLICATION_CREDENTIALS="/path/to/json/key/file" environment variable
# e.g. export GOOGLE_APPLICATION_CREDENTIALS="/users/caseycolby/.ssh/terraform-498@dev-346101-60917f23f0a2.json"
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/json/key/file" 
```

Navigate to the directory for the environment you want to deploy (e.g. dev) and run terraform commands 
```bash
cd iac/dev
terraform init # initialize the necessary providers and remote state
terraform plan # to view planned changes and verify they are as expected, without applying them 
terraform apply # to execute changes 
```

[^1]: In the future, this should be scripted; time did not allow in the scope of this project.

## Additional Setup in GCP 
### BigQuery ML Modeling and Export to AI Platform
Setup of some section of the app have yet to be scripted due to time constraints in the course: 
- For the Dataflow ETLs, initially google-provided templates are being used and the jobs are configured via the GCP console.
- The BigQuery ML commands are located in the `bq_ml_queries` directory. These can be executed via the console once you have terraformed everything. 
- Once you have run them BigQuery ML queries to create a model and test it out for batch predictions, use the console to export it to a cloud storage bucket. 
- In the AI Platform service, create a new Model Version of the terraformed model, pointing to the exported model in cloud storage (currently the python app expects it to be named `console_test`, but this should be parameterized eventually once more of this section is scripted out). 

### Running the Flask Prediction App locally 

This project includes a python app for obtaining online predictions from AI Platform. Running this app locally is a great starting point if you are new to API development, CICD, or Google App Engine.

Follow the documentation to install the Google Cloud SDK if you haven't already, to set up the gcloud command-line tool: https://cloud.google.com/sdk

Navigate to the 'service accounts' section of the GCP IAM console. Create a new JSON key and download the `App Engine default service account` JSON key to your local machine from GCP. Google App Engine uses a default service account named <PROJECT_ID>@appspot.gserviceaccount.com. 

Set the credentials: set the path to the key by setting the CLI GOOGLE_APPLICATION_CREDENTIALS variable with the path to the json key file on your machine. This enables you to run the code the same way Google App Engine would, from your command line. 
```bash
export GOOGLE_APPLICATION_CREDENTIALS="/path/to/json/key/file" 
```

navigate to the `gae_py_insurance` directory and install dependencies
```bash
# Python comes installed with the venv module 
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

Run the Flask API 
```bash
cd gae_py_insurance
python main.py
```

Visit localhost:8080 in your browser.
