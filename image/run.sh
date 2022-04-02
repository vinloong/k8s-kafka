#!/bin/bash

HOST=`hostname -s`
DOMAIN=`hostname -d`
CONFIG_FILE="/opt/kafka/config/kraft/server.properties"
ROLES="broker,controller"
NODE_COUNT=1

if [[ $HOST =~ (.*)-([0-9]+)$ ]]; then 
    NAME=${BASH_REMATCH[1]}
    ORD=${BASH_REMATCH[2]}
else
    echo "Fialed to parse name and ordinal of Pod"
    exit 1
fi

controller_quorum_voters=""

function print_brokers() {
    for ((i=1; i<= $NODE_COUNT; i++ ))
    do
        controller_quorum_voters=${controller_quorum_voters},$i@$NAME-$((i-1)).$DOMAIN:9093
    done
    controller_quorum_voters="controller.quorum.voters=${controller_quorum_voters:1}" 
}

function modify_config() {
    sed -i "s/process.roles=broker,controller/process.roles=${ROLES}/g" ${CONFIG_FILE}
    ADVERTISED_LISTENERS="advertised.listeners=PLAINTEXT://$HOST.$DOMAIN:9092"
    sed -i "s@advertised.listeners=PLAINTEXT://localhost:9092@${ADVERTISED_LISTENERS}@g" ${CONFIG_FILE}
    if [ $NODE_COUNT -gt 1 ]; then
        print_brokers
        sed -i "s/node.id=1/node.id=$((ORD+1))/g" ${CONFIG_FILE}
        sed -i "s/controller.quorum.voters=1@localhost:9093/${controller_quorum_voters}/g" ${CONFIG_FILE}
    fi   
}

optspec=":hv-:"
while getopts "$optspec" optchar; do
    case "${optchar}" in
        -)
            case "${OPTARG}" in
                roles=*)
                    ROLES=${OPTARG##*=}
                    ;;
                conf_dir=*)
                    CONFIG_FILE="${OPTARG##*=}/server.properties"
                    ;;
                node_count=*)
                    NODE_COUNT=${OPTARG##*=}
                    ;;    
                *)
                    echo "Unknown option --${OPTARG}" >&2
                    exit 1
                    ;;
            esac;;
        h)
            print_usage
            exit
            ;;
        v)
            echo "Parsing option: '-${optchar}'" >&2
            ;;
        *)
            if [ "$OPTERR" != 1 ] || [ "${optspec:0:1}" = ":" ]; then
                echo "Non-option argument: '-${OPTARG}'" >&2
            fi
            ;;
    esac
done


modify_config \ 
&& exec bin/kafka-storage.sh format -t `./bin/kafka-storage.sh random-uuid` -c ${CONFIG_FILE} --ignore-formatted \ 
&& exec ./bin/kafka-server-start.sh ${CONFIG_FILE}
