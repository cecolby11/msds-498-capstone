# Create the AI Platform service object.
# To authenticate set the environment variable
# GOOGLE_APPLICATION_CREDENTIALS=<path_to_service_account_file>
import googleapiclient.discovery

service = googleapiclient.discovery.build('ml', 'v1')

def predict_json(project, model, instances, version=None):
    """Send json data to a deployed model for prediction.

    Args:
        project (str): project where the AI Platform Model is deployed.
        model (str): model name.
        instances ([Mapping[str: Any]]): Keys should be the names of Tensors
            your deployed model expects as inputs. Values should be datatypes
            convertible to Tensors, or (potentially nested) lists of datatypes
            convertible to tensors.
        version: str, version of the model to target.
    Returns:
        Mapping[str: any]: dictionary of prediction results defined by the
            model.
    """
    name = 'projects/{}/models/{}'.format(project, model)

    if version is not None:
        name += '/versions/{}'.format(version)

    print(instances)
    response = service.projects().predict(
        name=name,
        body={'instances': instances}
    ).execute()

    print(response['predictions'])

    if 'error' in response:
        raise RuntimeError(response['error'])

    return response['predictions']


# instances = [
#         {"sex": "female", "age": 26, "smoker": False, "bmi":  27.315, "children": 0, "region": "northeast"},
#         {"sex": "male", "age": 55, "smoker": True, "bmi":  39.315, "children": 2, "region": "northeast"}
#     ]

# predict_json('dev-346101', 'simple_insurance', instances, 'console_test')
