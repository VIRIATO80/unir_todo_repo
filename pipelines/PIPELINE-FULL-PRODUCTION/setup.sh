#!/bin/bash

set -x
python3.7 -m venv todo-list-aws
source todo-list-aws/bin/activate
python -m pip install --upgrade pip
python -m pip install requests
# For integration testing
python -m pip install pytest

# For HTTP requests
python -m pip install requests
python3 -m pip install requests

pip install requests

pwd