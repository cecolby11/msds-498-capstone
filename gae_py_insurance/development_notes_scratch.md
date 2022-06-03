## Development Notes

Helpful Resource: 
https://cloud.google.com/ai-platform/prediction/docs/online-predict


```bash
python -m venv venv
source venv/bin/activate
pip3 install google-api-python-client
...
pip3 freeze > requirements.txt
...
deactivate
...
```
I had some issues of the python on my mac vs my venv version, because I did pip install of the google-api-python-client and then got `'googleapiclient' is not defined` type errors when running my script. so check which version of python is where:
```bash
which python
# python: aliased to /usr/local/bin/python3
which python3
# /Users/caseycolby/git/msds/msds-498-capstone/msds-498-capstone/src-python-client/venv/bin/python3
which pip
# pip: aliased to pip3
which pip3
# /Users/caseycolby/git/msds/msds-498-capstone/msds-498-capstone/src-python-client/venv/bin/pip3
``` 
so now I know to run my script with `python3 app.py`
