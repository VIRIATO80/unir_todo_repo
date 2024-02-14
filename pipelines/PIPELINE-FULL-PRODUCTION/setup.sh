#!/bin/bash

set -x
python3.10 -m venv todo-list-aws
source todo-list-aws/bin/activate
python -m pip install --upgrade pip
python -m pip install requests
# For integration testing
python -m pip install pytest
pwd