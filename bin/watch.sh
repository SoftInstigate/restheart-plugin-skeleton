#!/bin/sh

find ./src -name "*.java" | entr sh -c 'mvn clean package && docker stop restheart && docker start restheart'