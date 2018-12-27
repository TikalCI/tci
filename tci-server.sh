#!/bin/bash

set -e

cd tci-server

# prepare set-env,sh script from template
if [ ! -f .config ]; then
    cp ../src/resources/templates/tci-server/template.config .config
fi
if [ ! -f .config.yml ]; then
    cp ../src/resources/templates/tci-server/template.config.yml config.yml
fi

# activate set-env.sh script
source .config

# set action defaulted to 'restart'
action='restart'
if [[ $# > 0 ]]; then
   action=$1
fi

if [ ! -n "$TCI_HOST_IP" ]; then
    export TCI_HOST_IP="$(/sbin/ifconfig | grep 'inet ' | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1 | sed -e 's/addr://')"
fi
export GIT_PRIVATE_KEY=`cat $GITHUB_PRIVATE_KEY_FILE_PATH`


if [[ "$action" == "stop" || "$action" == "restart" ]]; then
   docker-compose down --remove-orphans
   sleep 2
fi

if [[ "$action" == "start"  || "$action" == "restart" ]]; then

    docker pull tikalci/tci-master
    docker tag tikalci/tci-master tci-master

    mkdir -p .data/jenkins_home/userContent
    cp -f ../src/resources/images/tci-small-logo.png .data/jenkins_home/userContent | true
    cp -f ../src/resources/config/templates/tci-server/tci.css .data/jenkins_home/userContent | true
    cp -f ../src/resources/config/org.codefirst.SimpleThemeDecorator.xml .data/jenkins_home | true
    docker-compose up -d
    sleep 2
    docker-compose logs -f | while read LOGLINE
    do
       echo -n .
       [[ "${LOGLINE}" == *"Entering quiet mode. Done..."* ]] && pkill -P $$ docker-compose
    done

fi
