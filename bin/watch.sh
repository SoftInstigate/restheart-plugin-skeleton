#!/bin/sh

find ./src -name "*.java" | entr sh -c 'mvn package; docker stop restheart; docker start restheart'