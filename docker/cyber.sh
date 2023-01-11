#!/usr/bin/env /bin/bash

Green="\033[1;92m"    # Green
Reset="\033[0m"       # Text Reset

PROJECT_HOME=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
DOCKER_COMPOSE="${PROJECT_HOME}/docker-compose.yml"
DOCKER_COMPOSE_SETUP="${PROJECT_HOME}/docker-compose.setup.yml"


while [[ $# -gt 0 ]]
do
  key="$1"

  case "$key" in
    setup)
      docker-compose -f "$DOCKER_COMPOSE_SETUP" up --build
    ;;
    up)
      docker-compose -f "$DOCKER_COMPOSE" up -d --build --remove-orphans
      docker exec -it filebeat sh -c "ulogd -d"
      docker exec --privileged -it filebeat /home/iptables-rules.sh
      exit
    ;;
    down)
      docker-compose -f "$DOCKER_COMPOSE" down --volumes
      exit
    ;;
    clean)
      rm -r $PROJECT_HOME/secrets/*
      exit
    ;;
  esac

  shift
done

echo -en """
Usage:
  - ${Green}setup${Reset}: creazione dei certificati di sicurezza
  - ${Green}up${Reset}: start dei servizi
  - ${Green}down${Reset}: stop sei servizi docker
  - ${Green}clean${Reset}: rimuove tutti i file generati da setup
"""

