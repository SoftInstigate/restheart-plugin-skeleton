#!/bin/bash

function help_message() {
    echo "Usage: $0 -p <profile>"
    echo "profiles: restheart, microd"
}

if [ $# -ne 2 ]; then
    echo "Wrong number of parameters: $#"
    help_message
    exit 1
fi

opts_flag=0

while getopts ":p:" o; do
    case "${o}" in
        -?)
            help_message
            exit 0
            ;;
        p)
            profile=${OPTARG}
            case "${OPTARG}" in
                restheart)
                    opts_flag=1
                    ;;
                microd)
                    opts_flag=1
                    ;;
                *)
                    help_message
                    exit 4
                    ;;
            esac
            ;;
        *)
            help_message
            exit 4
            ;;
    esac
done

[ $opts_flag -eq 0 ] && help_message && exit 2

find .  \( -path './src/*' -and -name "*.java" \)  -or -path './etc/*.yml'  -or -path './etc/*.properties' | entr sh -c "mvn clean package &&  ./bin/restart.sh $*"
