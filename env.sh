export COURSE=${PWD##*/}
export PORT=9876
export LOCAL_NOTEBOOK_IMAGE=jupytercloud/minimal-notebook
export HOST_DATA_VOLUME=${PWD}/data
export NB_UID=`id -u`
export NB_GID=`id -g`

mkdir -p ${HOST_DATA_VOLUME}/$COURSE/admin
touch ${HOST_DATA_VOLUME}/$COURSE/admin/grantlist.txt
