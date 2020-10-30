#!/bin/bash

cd /opt/watcher
nohup npm run watch &

cd /opt/restheart
exec java -Dfile.encoding=UTF-8 -server -jar restheart.jar etc/restheart.yml --envFile etc/default.properties