# RESTHeart Plugin Skeleton Project

This repository provides a skeleton project to build RESTHeart Plugins.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

### Requirements

- Java 11+
- Maven
- Docker
- entr

The script `watch.sh` requires [entr](https://github.com/eradman/entr)

You can install it on Mac with:

```bash
$ brew install entr
```

For Linux, please refer to [entr GitHub repo](https://github.com/eradman/entr).

entr is not available for Windows. You need to use the [Linux Subsystem](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to run the `watch.sh`.

## Start the server in development mode

### RESTHeart

Use the `docker-compose.yml` to start RESTHeart in development mode, i.e. with the JVM allowed to be remotely debugged on port 4000

```bash
$ mvn clean package
$ docker-compose up
```

#### Init MongoDB

The script `docker/docker-entrypoint-initdb.d/initdb.js` is executed by the mongo shell in the MongoDB container and allows initializing MongoDB, for instance creating test data.

#### Get notified when container restheart

The following command can be used to get notified on OSX when the RESTHeart container is restarted.

```bash
& docker-compose up | awk '/RESTHeart started/ { system("./bin/notify_osx.sh RESTHeart restarted") } /.*/'
```

If you are on Linux, you can tweak the command (`notify_osx.sh` is specific for OSX). Have a look at [this article](https://superuser.com/questions/31917/is-there-a-way-to-show-notification-from-bash-script-in-ubuntu) for some ideas. 

### microD

Use the `docker-compose-microd.yml` to start RESTHeart without the MongoDB Service. We call this profile **microD**, because it is an effective runtime environment for micro-services.

```bash
$ mvn package
$ docker-compose -f docker-compose-microd.yml up
```

And with notifications:

```bash
& docker-compose -f docker-compose-microd.yml up | awk '/RESTHeart stopped/ { system("./bin/notify_osx.sh RESTHeart stopped") } /RESTHeart started/ { system("./bin/notify_osx.sh RESTHeart started") }  /.*/'
```

## Watch: automatic rebuilding and restarting

You can use the `watch.sh` script, to have the project automatically rebuilt, and the RESTHeart container automatically restarted whenever a source or configuration file changes.

Use `watch.sh` after `docker-compose.up`

```bash
$ ./bin/watch.sh
```

## Hot Code Replace

The RESTHeart container uses the Java virtual machine (dcevm)(http://dcevm.github.io), that allows extended Hot Code Replace.

For even quicker code modifications, you can stop the script `watch.sh`, attach the debugger (on port 4000) and use the Hot Code Replace feature of your IDE.

### Get notified when building

```bash
$ ./bin/watch.sh | awk '/BUILD SUCCESS/ { system("./bin/notify_osx.sh RESTHeart build:success") } /BUILD FAILURE/ { system("./bin/notify_osx.sh RESTHeart build:failure") } /Building / { system("./bin/notify_osx.sh RESTHeart building...") } /.*/'
```

If you are on Linux, you can tweak the command (`notify_osx.sh` is specific for OSX). Have a look at [this article](https://superuser.com/questions/31917/is-there-a-way-to-show-notification-from-bash-script-in-ubuntu) for some ideas.

## RESTHeart Configuration

The directory `etc` contains the configuration files that are shared with the RESTHeart via the directive `volume` in the `docker-compose.yml`.

When a configuration file is modified, the container RESTHeart is automatically restarted.

## Dependencies

The dependencies jars are copied by the `maven-dependency-plugin` to the `target/lib` directory. Those jars are added to the classpath of RESTHeart when the container starts.

> When you add a dependency, you must restart the RESTHeart container. The easiest way to do it is restarting `watch.sh`.

### Avoid duplicate jars

`restheart.jar` embeds several jars. You should avoid adding to the classpath a jar that is already included in it.

You can avoid a dependency to be added to the classpath by specifying the scope `provided` in the pom dependency. For instance, the `restheart-commons` dependency has the scope `provided` because it is already embedded in `restheart.jar`:

```xml
<dependency>
    <groupId>org.restheart</groupId>
    <artifactId>restheart-commons</artifactId>
    <version>5.1.5</version>
    <scope>provided</scope>
</dependency>
```

Other libraries that are embedded in `restheart.jar` are the MongoDB driver and Unirest http library.

You can check which libraries are embedded in `restheart.jar` as follows:

```bash
$ git clone https://github.com/SoftInstigate/restheart.git && cd restheart
$ mvn dependency:tree -Dscope=compile
```

## ROADMAP

Future improvements are documented in [ROADMAP.md](ROADMAP.md)

## How to change the jar filename

The jar filename, is defined in `pom.xml` as equal to the artifactId.

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

**HTTP Shell**

> download HTTP Shell from [GitHub](https://github.com/SoftInstigate/http-shell/releases)

```bash
> h set url :8080
> h get /srv
```

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
