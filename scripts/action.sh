#! /bin/bash

set -e

DOCKER_FULL_IMAGE_NAME="$ECR_REGISTRY/$DOCKER_IMAGE_NAME"

# Determine Build Args
if [[ "$DOCKER_EXTRA_ARGS" != "" ]]; then
    export IFS=","
    DOCKER_ARGS_LIST=""
    for arg in $DOCKER_EXTRA_ARGS; do
        DOCKER_ARGS_LIST="$DOCKER_ARGS_LIST --build-arg $arg"
    done
else
    DOCKER_ARGS_LIST=""
fi

# Build the Docker image
echo "*** Building Dockerfile ***"
docker build -t "$DOCKER_FULL_IMAGE_NAME:$DOCKER_TAG" -f $DOCKERFILE_PATH $DOCKER_CONTEXT --no-cache $DOCKER_ARGS_LIST
docker tag "$DOCKER_FULL_IMAGE_NAME:$DOCKER_TAG" "$DOCKER_FULL_IMAGE_NAME:latest"

# Create the ECR Repository
echo "*** Creating ECR Repository ***"
aws ecr create-repository --repository-name $ECR_REPO_NAME || echo "Repository exists already. Skipping creation."

docker push $DOCKER_FULL_IMAGE_NAME:$DOCKER_TAG
docker push $DOCKER_FULL_IMAGE_NAME:latest