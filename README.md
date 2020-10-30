# RESTHeart Plugin Skeleton Project

This repository provides a skeleton project to build RESTHeart Plugins.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

## Start the server in development mode

You can get the project automatically rebuilt every time there is a change in the source code with the following maven command.

```
$ mvn fizzed-watcher:run
```

You can also start the server with docker-compose and have the container updated and restarted every time the plugin jar is rebuilt.

```
$ docker-compose up

```

## TestService

The code includes a super simple "Hello World" service. You can test it as follows:

**httpie**

```bash
$ http :8080/srv

{
    "msg": "Hello World!"
}
```

**curl**

```bash
$ curl :8080/srv

{"msg":"Hello World!"}%
```

## Requirements

- Java 11+
- Maven 3.6+
- Docker 1.8.1 (v1.20) is required for `docker:watch`