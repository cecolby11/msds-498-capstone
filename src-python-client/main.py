import flask
from predict import predict_json
# If `entrypoint` is not defined in app.yaml, App Engine will look for an app
# called `app` in `main.py`.
app = flask.Flask(__name__)

@app.get("/")
def hello():
    """Return a friendly HTTP greeting."""
    return "Hello World!\n"

@app.get('/predict/create')
def serve_predict_form():
  """Display an HTML form for prediction"""
  return flask.render_template('predict.html')
  

@app.post('/predict')
def predict():
  """Return a prediction from AI Platform"""
  sex = flask.request.form['sex']
  age = int(flask.request.form['age'])
  children = int(flask.request.form['children'])
  smoker = flask.request.form['smoker']
  if smoker == '0':
    boolean_smoker = False
  else:
    boolean_smoker = True
  bmi = float(flask.request.form['bmi'])
  region = flask.request.form['region']

  instances = [{"sex": sex, "age": age, "smoker": boolean_smoker, "bmi":  bmi, "children": children, "region": region}]
  result = predict_json('dev-346101', 'simple_insurance', instances, 'console_test')
  print(result)
  charges = round(result[0]['predicted_charges'][0],2)
  print(charges)
  # return str(charges)
  data = {"sex": sex, "age": age, "smoker": boolean_smoker, "bmi":  bmi, "children": children, "region": region, "charges" :charges}
  return flask.render_template('prediction.html', data=data)



if __name__ == "__main__":
    # Used when running locally only. When deploying to Google App
    # Engine, a webserver process such as Gunicorn will serve the app. This
    # can be configured by adding an `entrypoint` to app.yaml.
    app.run(host="localhost", port=8080, debug=True)

# instances = [
#         {"sex": "female", "age": 26, "smoker": False, "bmi":  27.315, "children": 0, "region": "northeast"},
#         {"sex": "male", "age": 55, "smoker": True, "bmi":  39.315, "children": 2, "region": "northeast"}
#     ]

# predict_json('dev-346101', 'simple_insurance', instances, 'console_test')
