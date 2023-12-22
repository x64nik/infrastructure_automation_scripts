#!/usr/bin/bash

# How to run ?
# (with doppler token) ./deploy-apis.sh <image_name> <dockerhub_username> <dockerhub_password> <host_port> <container_port> <doppler_token>
# (without doppler token) ./deploy-apis.sh <image_name> <dockerhub_username> <dockerhub_password> <host_port> <container_port>

IMAGE=$1
DOCKERHUB_USERNAME=$2
DOCKERHUB_PASS=$3
HOST_PORT=$4
CONT_PORT=$5
DOPPLER_TOKEN=$6

IMAGE_IDs=$(docker images | grep "$IMAGE" | awk '{print $3}')
CONTAINER_IDs=$(docker ps -a | grep "$IMAGE" | awk '{print $1}')

FOUND_CONTAINERS=$CONTAINER_IDs
FOUND_IMAGES=$IMAGE_IDs

# Deleting docker containers associated with image name 
if [[ ${FOUND_CONTAINERS} ]]
then
    for container_id in $CONTAINER_IDs
    do
      echo "stopping and removing container $container_id"
      docker stop $container_id
      docker rm $container_id
    done
fi

# Collecting unnamed container which is using specific port
RAW_CONTAINER_ID=$(docker ps -a | grep "0.0.0.0:$HOST_PORT" | awk '{print $1}')

# Deleting unnamed container
if [[ ${RAW_CONTAINER_ID} ]]
then
    echo "removing unnamed container running on external port $HOST_PORT"
    docker stop $RAW_CONTAINER_ID
    docker rm $RAW_CONTAINER_ID --force
fi


# removing images associated with image name 
if [[ ${FOUND_IMAGES} ]]
then
    for image_id in $IMAGE_IDs
    do
    echo "removing image $image_id"
    docker rmi $image_id --force
    done
fi

# Pulling and running updated docker image

echo "Starting deployment"
echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USERNAME --password-stdin 
docker login
docker pull $IMAGE

if [ -z "$DOPPLER_TOKEN" ]
then
    docker run -d --restart always -p $HOST_PORT:$CONT_PORT $IMAGE
else
    # image need some envs as token to run
    docker run -e DOPPLER_TOKEN=$DOPPLER_TOKEN --restart always -d -p $HOST_PORT:$CONT_PORT $IMAGE
fi

echo "UP and RUNNING :)"
