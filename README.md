# RESTHeart Plugin Skeleton Project

This repository provides a skeleton project to build RESTHeart Plugins.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

## Start the server in development mode

Use the `docker-compose.yml` to start RESTHeart in development mode, i.e. with the JVM allowed to be remotely debugged on port 4000

```bash
$ docker-compose up
```

You can also use the `watch.sh` script, to have the project to automatically rebuilt, and the RESTHeart container automatically restarted whenever a source file changes.

Use `watch.sh` after `docker-compose.up`

```bash
$ ./bin/watch.sh
```

### requirements for watch.sh

The script `watch.sh` requires [entr](https://github.com/eradman/entr)

You can install it on Mac with:

```bash
$ brew install entr
```

For other OSes, please refer to [entr GitHub repo](https://github.com/eradman/entr)

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