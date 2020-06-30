#!/usr/bin/env bash

# This fetches the AWS CLI
# inflates it
# and sets location to the path
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# set the credentials to the default AWS CLI configuration file
mkdir ~/.aws # just in case the CLI did not create the file yet
AWS_CRED_FILE=~/.aws/credentials # just in case the CLI did not create the file yet
# make sure to pass the access and secret keys via the CI tool!
echo "[default]" > $AWS_CRED_FILE
echo -e "aws_access_key_id=$ACCESS_KEY" >> $AWS_CRED_FILE
echo -e "aws_secret_access_key=$SECRET_KEY" >> $AWS_CRED_FILE

# the $CIRCLE_BUILD_NUM variable is provided by CircleCI via the ENV's
# the idea here is to get a incremental version number
# the zip's name can be anything you like
zip -r app_v_$CIRCLE_BUILD_NUM.zip .ebextensions/ Dockerrun.aws.json

# upload the ZIP file to the beanstalk bucket
aws s3 cp ./app_v_$CIRCLE_BUILD_NUM.zip s3://elasticbeanstalk-REGION-ACCOUNT_ID/

# creating a new Beanstalk version from the configuration we uploaded to s3
aws elasticbeanstalk create-application-version \
--application-name YOUR_BEANSTALK_APPLICATION_NAME\ 
--version-label v$CIRCLE_BUILD_NUM \ ### => this can be anything you like, but it must be unique
--description="New Version number $CIRCLE_BUILD_NUM" \ ### => this can also be anything you like
--source-bundle S3Bucket="elasticbeanstalk-REGION-ACCOUNT_ID",S3Key="app_v_$CIRCLE_BUILD_NUM.zip" \ ### => this specifies the location of the ZIP file we previously uploaded
--auto-create-application \
--region=REGION

# deploying the new version to the given environment
aws elasticbeanstalk update-environment \
--application-name YOUR_BEANSTALK_APPLICATION_NAME \
--environment-name YOUR_BEANSTALK_ENVIRONMENT_NAME \
--version-label v$CIRCLE_BUILD_NUM \
--region=REGION