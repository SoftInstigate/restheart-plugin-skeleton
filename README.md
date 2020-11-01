# RESTHeart Plugin Skeleton Project

This repository provides a skeleton project to build RESTHeart Plugins.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

### Requirements

- Docker
- entr

The script `watch.sh` requires [entr](https://github.com/eradman/entr)

You can install it on Mac with:

```bash
$ brew install entr
```

For Linux, please refer to [entr GitHub repo](https://github.com/eradman/entr). 

entr is not available for Windows. You need to use the [Linux Subsystem](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

## Start the server in development mode

Use the `docker-compose.yml` to start RESTHeart in development mode, i.e. with the JVM allowed to be remotely debugged on port 4000

```bash
$ mvn package
$ docker-compose up
```

You can also use the `watch.sh` script, to have the project to automatically rebuilt, and the RESTHeart container automatically restarted whenever a source or configuration file changes.

Use `watch.sh` after `docker-compose.up`

```bash
$ ./bin/watch.sh
```

## RESTHeart Configuration

The directory `etc` contains the configuration files that are shared with the RESTHeart via the directive `volume` in the `docker-compose.yml`.

When a configuration file is modified, the container RESTHeart is automatically restarted.

## ROADMAP

Future improvements are documented in [ROADMAP.md](ROADMAP.md)

## Init db

the file `docker/docker-entrypoint-initdb.d/initdb.js` allows to init MongoDB

## How to change the jar filename

To jar filename, is defined in `pom.xml` as equal to the artifactId.

```xml
<artifactId>restheart-plugin-skeleton</artifactId>
...
<build>
 <finalName>${project.artifactId}</finalName>
 ...
</build>
```

When you update the artifactId in the `pom.xml`, you need to update the volume section of the service restheart in the `docker-compose.yml` 

From:

```yml
volumes:
    - ./target/restheart-plugin-skeleton.jar:/opt/restheart/plugins/restheart-plugin-skeleton.jar
```

To:

```yml
volumes:
 - ./target/<your-artifactId>.jar:/opt/restheart/plugins/<your-artifactId>.jar
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