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
    export PORT=8000
fi
netstat -tunpl 2>/dev/null | grep :$PORT >/dev/null
if [ $? -eq 0 ]
then
    echo ":$PORT already in use."
    exit 2
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

#JWT_SECRET_KEY=`openssl enc -aes256 -pbkdf2 -k jupytercloud-secret -md sha1 -P |grep key |cut -d'=' -f2`
JWT_SECRET_KEY=AF789192078DB4E2275A3CE0410E99E93B29A0C723A32652553A9C60E9C23A5B

SECRET_KEY=`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8 ; echo ''`

export JWT_SECRET_KEY
export SECRET_KEY

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
# Report
#

echo "Course is: $COURSE"
echo "Listening at port: $PORT"
echo "Data directory: $HOST_DATA_VOLUME"
echo "Docker image used: $COURSE_NOTEBOOK_IMAGE"

cmd=$1
case $cmd in
"up")
    docker-compose up -d
    ;;
"down")
    docker-compose down
    ;;
esac
