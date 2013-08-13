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

if [ -f "${DROPBOX_BASE}/${DATABASE_NAME}_database.sql" ]; then
    $ECHO_CMD "Database backup found. Restoring..."
    mysql -u${DATABASE_USER} -p ${DATABASE_NAME} < ${DROPBOX_BASE}/${DATABASE_NAME}_database.sql
else
    $ECHO_CMD "Database backup could not be found at ${DROPBOX_BASE}/${DATABASE_NAME}_database.sql"
fi

if [ -f "${DROPBOX_BASE}/${PROJECT_NAME}_media.tgz" ]; then
    $ECHO_CMD "Media backup found. Restoring..."
    tar xzvf ${DROPBOX_BASE}/${PROJECT_NAME}_media.tgz -C "${PROJECT_BASE}/public"
fi


