# RESTHeart Plugin Skeleton Project

This repository provides a skeleton project to build RESTHeart Plugins.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

### Requirements

- Java 11+
- Maven
- entr (for watch script)
- Docker (to start MongoDB with docker-compose)

The script `watch.sh` requires [entr](https://github.com/eradman/entr)

You can install it on Mac with:

```bash
$ brew install entr
```

For Linux, please refer to [entr GitHub repo](https://github.com/eradman/entr).

entr is not available for Windows. You need to use the [Linux Subsystem](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to run the `watch.sh`.

## Start RESTHeart in development mode

Use the script `./bin/restart.sh` to start the latest release of RESTHeart in development mode, i.e. run with the DCEVM JVM and enabled for debugging on port 4000

```bash
$ mvn clean package
$ ./bin/restart.sh -p restheart
```

> the script automatically deploys the plugin to RESTHeart

> the script automatically downloads RESTHeart and the DCEVM JVM in the `.cache` directory. Delete `.cache` and rerun the script to update RESTHeart to latest release.

You can check the log file with `tail -f /usr/local/var/log/restheart.log`

> log file path is set in `etc/dev.properties`

#### Get notified when RESTHeart restarts

The following command can be used to get notified on OSX when RESTHeart is restarted by the script `bin/watch.sh`.

```bash
& tail -f /usr/local/var/log/restheart.log | awk '/RESTHeart stopped/ { system("./bin/notify_osx.sh RESTHeart stopped") } /RESTHeart started/ { system("./bin/notify_osx.sh RESTHeart started") } /.*/'
```

If you are on Linux, you can tweak the command (`notify_osx.sh` is specific for OSX). Have a look at [this article](https://superuser.com/questions/31917/is-there-a-way-to-show-notification-from-bash-script-in-ubuntu) for some ideas.

### microD profile

Use the profile `microd` to start RESTHeart without the MongoDB Service. We call this profile **microD**, because it is an effective runtime environment for micro-services.

```bash
$ mvn clean package
$ ./bin/restart.sh -p microd
```

### MongoDB

You can use docker-compose to run MongoDB

```bash
& docker-compose up -d
```

> docker-compose runs MongoDB as a single instance replica set. This is required for transactions and change streams to work.

#### Init MongoDB

The script `docker/docker-entrypoint-initdb.d/initdb.js` is executed by the mongo shell in the MongoDB container and allows initializing MongoDB, for instance creating test data.

## Watch: automatic rebuilding and restarting

You can use the script `bin/watch.sh`, to have the project automatically rebuilt, and RESTHeart automatically restarted whenever a source or configuration file changes.

```bash
$ ./bin/watch.sh -p restheart
```

Or

```bash
$ ./bin/watch.sh -p microd
```

#### Get building notifications on OSX

The following command can be used to get notified on OSX when about building events triggered by the script `bin/watch.sh`

```bash
$ ./bin/watch.sh -p restheart | awk '/BUILD SUCCESS/ { system("./bin/notify_osx.sh RESTHeart build:success") } /BUILD FAILURE/ { system("./bin/notify_osx.sh RESTHeart build:failure") } /Building / { system("./bin/notify_osx.sh RESTHeart building...") } /.*/'
```

## Hot Code Replace

The script `bin/restart.sh` runs RESTHeart with the Java Virtual Machine (dcevm)(http://dcevm.github.io), that features *extended Hot Code Replace*.

For even quicker code modifications, you can stop the script `bin/watch.sh`, attach the debugger (on port 4000) to use the Hot Code Replace feature of your IDE.

## RESTHeart Configuration

The directory `etc` contains the configuration files that are used by the script `bin/restheart.sh`.

When a configuration file is modified, the container RESTHeart is automatically restarted by the script `bin/watch.sh`.

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
