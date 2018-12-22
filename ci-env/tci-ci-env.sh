#!/bin/bash

# prepare set-env,sh script from template
if [ ! -f set-env.sh ]; then
    cp set-env.sh.template set-env.sh
    chmod +x set-env.sh
fi

# activate set-env.sh script
. set-env.sh

# set action defaulted to 'restart'
action='restart'
if [[ $# > 0 ]]; then
   action=$1
fi

export TCI_HOST_IP="$(/sbin/ifconfig | grep 'inet ' | grep -Fv 127.0.0.1 | awk '{print $2}' | head -n 1 | sed -e 's/addr://')"
export GIT_PRIVATE_KEY=`cat $GITHUB_PRIVATE_KEY_FILE_PATH`

if [[ "$action" == "stop" || "$action" == "restart" || "$action" == "clean-restart" || "$action" == "reset" ]]; then
   docker-compose down --remove-orphans
   sleep 2
fi

if [[ "$action" == "clean" || "$action" == "clean-restart" || "$action" == "clean-start" ]]; then
    echo 'Nothing to do for now'
    # TODO clean files to enable fresh start
fi

if [[ "$action" == "stop" || "$action" == "restart" || "$action" == "clean-restart" || "$action" == "reset" ]]; then
   rm -rf .data
   docker rmi tci-master
fi

if [[ "$action" == "start" || "$action" == "clean-start"  || "$action" == "restart" || "$action" == "clean-restart" || "$action" == "reset" ]]; then

    if [ -d tci-master ]; then
        cd tci-master
        git fetch origin
    else
        git clone git@github.com:TikalCI/tci-master.git
        cd tci-master
    fi
    git fetch origin
    git checkout $TCI_MASTER_BRANCH | true
    git pull origin $TCI_MASTER_BRANCH
    docker build -t tci-master .

    cd ..

    cat config.yml.template > config.yml
    cat seed-test-jobs >> config.yml
    docker-compose up -d
    sleep 2
    docker-compose logs -f
fi
