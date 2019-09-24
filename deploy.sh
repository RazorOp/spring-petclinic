#!/bin/sh

set -ex

TOMCAT_DIR=/opt/tomcat/webapps

test -n "$INSTANCE"
test -n "$PACKAGE_PATH"

WAR_NAME_PREFIX=$CI_REPO_NAME
APP_NAME="$WAR_NAME_PREFIX-$CI_WORKFLOW_NUMBER"
WAR_NAME="$APP_NAME.war"
TMP_SCP_PATH="/tmp/$WAR_NAME"

scp $PACKAGE_PATH "$INSTANCE:$TMP_SCP_PATH"

ssh $INSTANCE TMP_SCP_PATH=$TMP_SCP_PATH TOMCAT_DIR=$TOMCAT_DIR WAR_NAME=$WAR_NAME WAR_NAME_PREFIX=$WAR_NAME_PREFIX 'bash -s' <<-'ENDSSH'
    sudo mv $TMP_SCP_PATH $TOMCAT_DIR/$WAR_NAME
    sudo find $TOMCAT_DIR -type f -name "$WAR_NAME_PREFIX*" -ctime +30 -exec rm {} \;
ENDSSH

# sudo service tomcat restart


if [ -n "$WEB_ADDRESS" ]; then
    echo "Your code is deployed at $WEB_ADDRESS/$APP_NAME/"        
else
    echo "Your code is deployed at <host:port>/$APP_NAME/"
fi