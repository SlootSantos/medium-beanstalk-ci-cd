#!/usr/bin/env bash

# the $CIRCLE_BUILD_NUM variable is provided by CircleCI via the ENV's
# the idea here is to get a incremental version number
# the zip's name can be anything you like
zip -r app_v_$CIRCLE_BUILD_NUM.zip .ebextensions/ Dockerrun.aws.json