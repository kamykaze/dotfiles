#!/bin/bash

# This script backups up the media and database of a project and puts into your Dropbox location

PROJECT_NAME="$1"
if [ -z $2 ]; then
    POSTFIX=""
else
    POSTFIX="$2"
fi
DROPBOX_BASE="${HOME}/Dropbox/project_data"
PROJECT_BASE="${HOME}/dev/projects/webcube-$1$POSTFIX/$1"
DATABASE_NAME="$1$POSTFIX"
DATABASE_USER="root"
#DATABASE_PASSWORD=""
ECHO_CMD="echo"


if [ -z $1 ]; then
    $ECHO_CMD "A project name must be specified;"
    $ECHO_CMD "Usage: $0 myproject [postfix]"
    exit
fi

if [ -d "$DROPBOX_BASE" ]; then
    $ECHO_CMD "${DROPBOX_BASE} exists...proceeding"
else
    $ECHO_CMD "${DROPBOX_BASE} does not exist...creating directory"
    mkdir -p ${DROPBOX_BASE}
fi

mysqldump -u${DATABASE_USER} -p ${DATABASE_NAME} --skip-lock-tables > ${DROPBOX_BASE}/${DATABASE_NAME}_database.sql
cd "${PROJECT_BASE}/public" && tar czvf ${DROPBOX_BASE}/${PROJECT_NAME}_media.tgz "media" && cd -

