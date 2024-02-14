#!/bin/bash

set -x
python3.10 -m venv todo-list-aws
source todo-list-aws/bin/activate
# For integration testing
python3 -m pip install pytest
pwd