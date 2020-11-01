#!/bin/bash

exec java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=0.0.0.0:4000 -Dfile.encoding=UTF-8 -server -jar restheart.jar etc/restheart.yml --envFile etc/default.properties