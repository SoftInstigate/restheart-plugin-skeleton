#!/bin/sh

function help_message() {
    echo "Usage: $0 -p <profile>"
    echo "profiles: restheart, microd"
}

if [ $# -ne 2 ]; then
    echo "Wrong number of parameters: $#"
    help_message
    exit 1
fi

CD="$( dirname "${BASH_SOURCE[0]}" )"/..
RH=$CD/.cache/restheart

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
                    CONFIG_FILE=etc/restheart.yml
                    [ -f $RH/plugins/restheart-mongodb.disabled ] &&  mv $RH/plugins/restheart-mongodb.disabled $RH/plugins/restheart-mongodb.jar
                    ;;
                microd)
                    opts_flag=1
                    CONFIG_FILE=etc/microd.yml
                    [ -f $RH/plugins/restheart-mongodb.jar ] && mv $RH/plugins/restheart-mongodb.jar $RH/plugins/restheart-mongodb.disabled
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

if [ ! -d ".cache" ]
then
    if [ "$(uname)" == "Darwin" ]; then
        DCEVM_URL=https://github.com/TravaOpenJDK/trava-jdk-11-dcevm/releases/download/dcevm-11.0.9%2B2/java11-openjdk-dcevm-osx.tar.gz
    else
        DCEVM_URL=https://github.com/TravaOpenJDK/trava-jdk-11-dcevm/releases/download/dcevm-11.0.9%2B2/java11-openjdk-dcevm-linux.tar.gz
    fi

    echo **** Downloading RESTHeart..
    mkdir .cache && cd .cache
    curl -L https://gitreleases.dev/gh/softInstigate/restheart/latest/restheart.tar.gz --output restheart.tar.gz
    tar -xzf restheart.tar.gz
    echo **** Downloading DCEVM..
    curl -L $DCEVM_URL > dcevm.tar.gz
    tar -xzf dcevm.tar.gz
    cd ..
fi

cp $CD/etc/*.properties .cache/restheart/etc
cp $CD/etc/*.yml .cache/restheart/etc

if [ "$(uname)" == "Darwin" ]; then
    JAVA_BIN=$CD/.cache/dcevm-11.0.9+1/Contents/Home/bin
else
    JAVA_BIN=$CD/.cache/dcevm-11.0.9+1/bin
fi

echo Killing restheart
kill -9 `lsof -t -i:8080` 2> /dev/null || echo .. > /dev/null

echo Deploying plugin
cp target/*.jar $RH/plugins
cp target/lib/*.jar $RH/plugins

LOG_FILE=/usr/local/var/log/restheart.log

echo Starting restheart, check log with:
echo \> tail -f $LOG_FILE
echo \> tail -f $LOG_FILE \| awk \'/RESTHeart stopped/ \{ system\(\"./bin/notify_osx.sh RESTHeart stopped\"\) \} /RESTHeart started/ \{ system\(\"./bin/notify_osx.sh RESTHeart restarted\"\) \}  /.*/\'

$JAVA_BIN/java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:4000 -jar $RH/restheart.jar $RH/$CONFIG_FILE -e $RH/etc/dev.properties > /dev/null &