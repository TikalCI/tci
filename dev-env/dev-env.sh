#!/bin/bash

# prepare set-env,sh script from template
if [ ! -f .config ]; then
    cp ../src/resources/templates/dev-env/template.config .config
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

if [[ "$action" == "reset" ]]; then
    read -p "Are you sure you want to reset tci dev-env [y/N]? " -n 1 -r
    echo    # (optional) move to a new line
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
    fi
fi

if [[ "$action" == "stop" || "$action" == "restart" || "$action" == "clean-restart" || "$action" == "reset" ]]; then
   docker-compose down --remove-orphans
   sleep 2
fi

if [[ "$action" == "clean" || "$action" == "clean-restart" || "$action" == "clean-start" ]]; then
    echo 'Nothing to do for now'
    # TODO clean files to enable fresh start
fi

if [[ "$action" == "reset" ]]; then
   rm -rf .data
   docker rmi tci-master
fi

if [[ "$action" == "start" || "$action" == "clean-start"  || "$action" == "restart" || "$action" == "clean-restart" || "$action" == "reset" ]]; then

    if [[ "$TCI_MASTER_BUILD_LOCAL" == "true" ]]; then
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
    else
        docker pull tikalci/tci-master
        docker tag tikalci/tci-master tci-master
    fi

    cat ../src/resources/templates/dev-env/base.config.yml > config.yml
    cat ../src/resources/templates/dev-env/seed.test.jobs.yml >> config.yml
    mkdir -p .data/jenkins_home/userContent
    cp -f ../src/resources/images/tci-small-logo.png .data/jenkins_home/userContent | true
    cp -f ../src/resources/templates/dev-env/tci.css .data/jenkins_home/userContent | true
    cp -f ../src/resources/config/org.codefirst.SimpleThemeDecorator.xml .data/jenkins_home | true
    docker-compose up -d
    sleep 2
    docker-compose logs -f
fi
