#!/usr/bin/env bash

# the $CIRCLE_BUILD_NUM variable is provided by CircleCI via the ENV's
# the idea here is to get a incremental version number
# the zip's name can be anything you like
zip -r app_v_$CIRCLE_BUILD_NUM.zip .ebextensions/ Dockerrun.aws.json

# installing the AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install