#!/usr/bin/env bash

# This fetches the AWS CLI
# inflates it
# and sets location to the path
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip &> /dev/null
sudo ./aws/install &> /dev/null

## for AWS CLI v2 you need to install "less"
sudo apt-get update && sudo apt-get install -yy less

# set the credentials to the default AWS CLI configuration file
mkdir ~/.aws # just in case the CLI did not create the file yet
AWS_CRED_FILE=~/.aws/credentials # just in case the CLI did not create the file yet
# make sure to pass the access and secret keys via the CI tool!
echo "[default]" > $AWS_CRED_FILE
echo -e "aws_access_key_id=$ACCESS_KEY" >> $AWS_CRED_FILE
echo -e "aws_secret_access_key=$SECRET_KEY" >> $AWS_CRED_FILE

##### setting ENV variables #####
YOUR_BEANSTALK_APPLICATION_NAME="ci_cd"
YOUR_BEANSTALK_ENVIRONMENT_NAME="ci-cd-env"
REGION="us-east-1"
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')
#################################

# the $CIRCLE_BUILD_NUM variable is provided by CircleCI via the ENV's
# the idea here is to get a incremental version number
# the zip's name can be anything you like
zip -r app_v_$CIRCLE_BUILD_NUM.zip Dockerrun.aws.json

# upload the ZIP file to the beanstalk bucket
aws s3 cp ./app_v_$CIRCLE_BUILD_NUM.zip s3://elasticbeanstalk-$REGION-$ACCOUNT_ID/

# creating a new Beanstalk version from the configuration we uploaded to s3
aws elasticbeanstalk create-application-version \
--application-name $YOUR_BEANSTALK_APPLICATION_NAME \
--version-label v$CIRCLE_BUILD_NUM \
--description="New Version number $CIRCLE_BUILD_NUM" \
--source-bundle S3Bucket="elasticbeanstalk-$REGION-$ACCOUNT_ID",S3Key="app_v_$CIRCLE_BUILD_NUM.zip" \
--auto-create-application \
--region=$REGION

# deploying the new version to the given environment
aws elasticbeanstalk update-environment \
--application-name $YOUR_BEANSTALK_APPLICATION_NAME \
--environment-name $YOUR_BEANSTALK_ENVIRONMENT_NAME \
--version-label v$CIRCLE_BUILD_NUM \
--region=$REGION

exit 0
