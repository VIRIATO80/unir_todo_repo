#!/bin/bash

set -x
python3.11 -m venv todo-list-aws
source todo-list-aws/bin/activate
python3 -m pip install --upgrade pip
#For integration testing
python3 -m pip install pytest
# For HTTP requests
python3 -m pip install requests

pwd