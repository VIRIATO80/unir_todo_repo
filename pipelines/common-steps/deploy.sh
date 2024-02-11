#!/bin/bash

set -x
du -hs * | sort -h
sam deploy --config-env ${ENVIRONMENT} --no-confirm-changeset --force-upload --no-fail-on-empty-changeset --no-progressbar --resolve-s3