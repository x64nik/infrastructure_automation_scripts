#!/bin/bash 

###################################################################
#       Script Name    : DockerKiller
#       Description    : This script will stop and remove docker
#						 image and container associated with any
#						 specific image name
#       Args           : image name, docker username/password, port
#       Author         : x64nik
#       Github         : https://github.com/x64ni
###################################################################

#DOPPLER_TOKEN=$1
IMAGE=$1
DOCKERHUB_USERNAME=$2
DOCKERHUB_PASS=$3
PORT=$4

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

RAW_CONTAINER_ID=$(docker ps -a | grep "$PORT" | awk '{print $1}')

# Deleting unnamed container
if [[ ${RAW_CONTAINER_ID} ]]
then
    echo "removing unnamed container running on port $PORT"
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
docker run -d -p $PORT:3000 $IMAGE

echo "UP and RUNNING :)"
