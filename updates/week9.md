# Week 9

## Project Recap & Week 9 Updates
### Previous weeks:
- Loaded data from Cloud Storage Bucket to BigQuery with Dataflow job
- Created a model with BigQuery ML to predict insurance charges 
- Created AI Platform Prediction model from exported model for online prediction 
- Creating Python app to call AI Platform model and make online predictions 
### Last week: 
- Deployed python app to Google App Engine
### This week: 
- Creating a custom DataFlow template (vs. google-provided template via the console) 
- helpful tutorials, docs, and starter code:
  - https://cloud.google.com/dataflow/docs/guides/templates/using-flex-templates
  - https://github.com/GoogleCloudPlatform/python-docs-samples/tree/main/dataflow/flex-templates/streaming_beam

## Pipeline Deployment
```bash
# authenticate
gcloud auth activate-service-account --key-file=/users/caseycolby/.ssh/terraform-498@dev-346101-60917f23f0a2.json  
# configure project as default
gcloud config set project dev-346101 

# set variable for template image tag
export TEMPLATE_IMAGE="gcr.io/$PROJECT/samples/dataflow/streaming-beam:latest"
# build template image from Dockerfile and tag it - uses Google Cloud Build and stores image in container registry
gcloud builds submit --tag "$TEMPLATE_IMAGE" .

# specify storage path for the dataflow job template to be created
export BUCKET=msds498_etl-dataflow-fxns  
export TEMPLATE_PATH="gs://$BUCKET/samples/dataflow/templates/streaming-beam-sql.json"

# build the dataflow job template and reference the docker image created
gcloud dataflow flex-template build $TEMPLATE_PATH \
      --image "$TEMPLATE_IMAGE" \
      --sdk-language "PYTHON" \
      --metadata-file "metadata.json"

# set variables for inputs/outputs (pub sub and big query)
export PROJECT=dev-346101
export DATASET=msds_498_warehouse
export TABLE=insurance_dev
export SUBSCRIPTION=example-subscription
export REGION=us-central1

# launch a dataflow job from the template!
gcloud dataflow flex-template run "streaming-beam-`date +%Y%m%d-%H%M%S`" \
    --template-file-gcs-location "$TEMPLATE_PATH" \
    --parameters input_subscription="projects/$PROJECT/subscriptions/$SUBSCRIPTION" \
    --parameters output_table="$PROJECT:$DATASET.$TABLE" \
    --region "$REGION"
```

## Dataflow Job Running
![dataflow job running](./Screen%20Shot%202022-05-22%20at%206.18.24%20PM.png)
