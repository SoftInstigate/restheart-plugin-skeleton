This docker image derives from softinstigate/restheart and uses npm-watch to kill the restheart process (thus terminating the docker container) whenever the plugin jar file changes.

docker-compose restarts the restheart container automatically