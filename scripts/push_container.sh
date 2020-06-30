#!/usr/bin/env bash

# login to ECR which sets a auth token to the ENV
$(aws ecr get-login --no-include-email --region REGION)

# build the container the way you always build it
docker build -t REGISTRY/IMG_NAME:latest -f "${PWD}/Dockerfile" ${PWD}

# get your latest image's ID
IMAGE_ID=$(docker images -q REGISTRY/IMG_NAME:latest)
ECR_URL=YOUR_ECR_URL

# tag it
docker tag $IMAGE_ID $ECR_URL:latest
# push it
docker push $ECR_URL:latest