# msds-498-capstone

## Setting up a new environment in GCP[^1]
- Within the `iac` directory, duplicate an existing terraform environment directory and rename it for your environment. 
- Create a new project in the GCP console for the new environment. Add the project ID to the `iac/{env}/variables.tf` in the `iac/{env}` directory. [^2]
- Per project: Via the GCP storage console, create a new private storage bucket for your account terraform state files. Update the bucket name in `iac/{env}/state.tf`. 
- Per project: Create a new `terraform` service account for Terraform via the GCP IAM console before running commands. Give it the following roles:

  | Role | Purpose | 
  | --- | --- | 
  | Storage Object Admin | To create and update remote statefile - object creator is enough to create a statefile but isn't sufficient to obtain the terraform lockfile, changing to object admin resolves the issue. |
  | Roles Administrator | To create other IAM Roles | 
  | Storage Object Viewer | Needed only if you need to run `terraform init -migrate-state`. |
  | Storage Admin | To create storage buckets. |
  | BigQuery User | To create datasets. |
- Per project: Enable the necessary APIs in the console [^4]
  - Identity and Access Management (IAM) API
  - Cloud Storage API
  - Data Flow API 

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
