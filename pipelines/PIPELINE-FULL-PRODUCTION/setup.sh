#!/bin/bash

set -x
python3.10 -m venv todo-list-aws
python -m pip install pytest
python -m pip install requests

pwd