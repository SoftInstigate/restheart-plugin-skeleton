#!/bin/bash

JAVA_BIN=/opt/java/dcevm-11.0.9+1/bin/

# copy the dependency jars to plugins directory to add them to the RESTHeart classpath
cp /opt/restheart/lib/* /opt/restheart/plugins



# execute RESTHeart
exec $JAVA_BIN/java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:4000 -Dfile.encoding=UTF-8 -server -jar restheart.jar etc/restheart.yml --envFile etc/dev.properties