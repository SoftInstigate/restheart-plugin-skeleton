#!/bin/sh

find .  \( -path './src/*' -and -name "*.java" \)  -or -path './etc/*.yml'  -or -path './etc/*.properties' | entr sh -c 'mvn clean package && docker-compose restart restheart'