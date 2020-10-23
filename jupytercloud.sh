#!/bin/bash

if [[ ! -e "secret.env" ]]
then
    echo "secret.env is missing."
    cat templates/secret.env
    exit 1
else
    source ./secret.env
    if [[ -z "$GOOGLE_CLIENT_ID" ]]
    then
        echo '$GOOGLE_CLIENT_ID is empty.'
        exit 1
    fi
    if [[ -z "$GOOGLE_CLIENT_SECRET" ]]
    then
        echo '$GOOGLE_CLIENT_SECRET is empty.'
        exit 1
    fi
    export GOOGLE_CLIENT_SECRET
    export GOOGLE_CLIENT_ID
fi

#
# Set and check PORT
#
if [[ -z "$PORT" ]]
then
    echo '$PORT is not set'
    exit 3
fi
netstat -tunpl 2>/dev/null | grep :$PORT >/dev/null
if [ $? -eq 0 ]
then
    echo ":$PORT already in use."
fi



#
# Use current UID if not set
#
if [[ -z "$NB_UID" ]]
then
    export NB_UID=`id -u`
fi

#
# Use current GID if not set
#
if [[ -z "$NB_GID" ]]
then
    export NB_GID=`id -g`
fi

#
# Default COURSE_NOTEBOOK_IMAGE
#
if [[ -z "$COURSE_NOTEBOOK_IMAGE" ]]
then
    export COURSE_NOTEBOOK_IMAGE=jupytercloud/minimal-notebook
fi

export HOST_DATA_VOLUME=$PWD/data
export COURSE=${PWD##*/}

mkdir -p ${HOST_DATA_VOLUME}/$COURSE/admin
touch ${HOST_DATA_VOLUME}/$COURSE/admin/grantlist.txt

#
# Secret keys
#

JWT_SECRET_KEY=`openssl rand -hex 32`

export JWT_SECRET_KEY

#
# Initial accounts
#
if [[ ! -f "./accounts.yaml" ]]
then
    echo "accounts.yaml file is missing."
    echo "===="
    cat templates/accounts.yaml
    exit 3
fi

#
# JupyterHub cull_service is enabled by default. It could
# be turned off by setting DISABLE_CULLING=True
#
# export DISABLE_CULLING=True

#
# Report
#

echo "Course is:                    $COURSE"
echo "PORT:                         $PORT"
echo "COURSE_NOTEBOOK_IMAGE:        $COURSE_NOTEBOOK_IMAGE"
if [[ ! -z "$SINGLEUSER_CPUS" ]]
then
    echo "SINGLEUSER_CPUS:              $SINGLEUSER_CPUS"
fi
if [[ ! -z "$SINGLEUSER_MEM_LIMIT" ]]
then
    echo "SINGLEUSER_MEM_LIMIT:         $SINGLEUSER_MEM_LIMIT"
fi
echo
echo "NB_UID:                       $NB_UID"
echo "NB_GID:                       $NB_GID"
echo "Data directory:               $HOST_DATA_VOLUME"
echo "JWT_SECRET_KEY:               $JWT_SECRET_KEY"

pattern="(${COURSE}_)|(jupytercloud-${COURSE}-)"

cmd=$1
case $cmd in
"up")
    docker-compose up -d
    ;;
"down")
    docker ps -a --format "{{.ID}} {{.Names}}" | grep -E $pattern > /dev/null
    if [[ $? -eq 0 ]]
    then
        echo "Shutdown $COURSE..."
        docker rm -f `docker ps -a --format "{{.ID}} {{.Names}}" | grep -E $pattern| cut -f1 -d" "`
    else
        echo "$COURSE is not running."
    fi
    ;;
*)
    echo 
    echo "=========== Current deployment ============"
    docker ps -a --format "{{.Names}} {{.Status}}" | grep -E $pattern | sort
    echo
    echo 'make up # to start'
    echo 'make down # to stop'

    ;;
esac
