# msds-498-capstone

## Project Overview

### Architecture



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
.gitignore                    # Lists files that should not be tracked in source control
.terraform-version            # Configures terraform version for tfenv utility to install
.editorconfig                 # Configuration for code editors
```

### Data
The open dataset I am working with is `Medical Cost Personal Datasets` available on Kaggle: https://www.kaggle.com/datasets/mirichoi0218/insurance  

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
Setup of one section of the app has yet to be scripted due to time constraints: 
- The BigQuery ML commands are located in the `bq_ml_queries` directory. These can be executed via the console once you have terraformed everything. 
- Once you have run them BigQuery ML queries to create a model and test it out for batch predictions, use the console to export it to a cloud storage bucket. 
- In the AI Platform service, create a new Model Version of the terraformed model, pointing to the exported model in cloud storage (currently the python app expects it to be named `console_test`, but this should be parameterized eventually once more of this section is scripted out). 

### Google App Engine App
