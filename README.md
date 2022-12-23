# RESTHeart Plugin Skeleton

This repository provides a skeleton project for RESTHeart Plugins.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

## Quick start

```bash
$ git clone --depth 1 git@github.com:SoftInstigate/restheart-plugin-skeleton.git && cd restheart-plugin-skeleton
$ ./bin/rh.sh build -o "-s"
```

The `rh.sh` helper script builds the plugin and runs RESTHeart with it. The `-s` option (available from RESTHeart 7.2) disables the plugins depending on MongoDB; this avoids to start MongoDB for running it.

The project skeleton defines a dummy *Service* bound at `/srv`:

```bash
$ curl localhost:8080/srv
{"message":"Hello World!","rnd":"njXZksfKFW"}%
```

At first run, `rh.sh` also transparently downloads and installs RESTHeart in the `.cache` subdirectory.

## Requirements

- Java 17+
- Docker (optional, only needed to start MongoDB with docker-compose)
- RESTHeart v7.2+

NOTE: the current `rh.sh` script won't work for RESTHeart 6.x due to different configuration options. You can use the script at tag 6.x as follows:

```bash
$ git clone --branch 6.x --depth 1 git@github.com:SoftInstigate/restheart-plugin-skeleton.git && cd restheart-plugin-skeleton
```

The command `watch` requires [entr](https://github.com/eradman/entr)

You can install it on Mac with:

```bash
$ brew install entr
```

For Linux, please refer to [entr GitHub repo](https://github.com/eradman/entr).

entr is not available for Windows. Use the [Linux Subsystem](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to run the `rh watch`.

## Build and deploy

The helper script `./bin/rh.sh`, builds and deploys the plugin, automatically restarting RESTHeart. It also installs RESTHeart on first run.


```bash
$ ./bin/rh.sh build
```

the script automatically:
- downloads the latest version of RESTHeart into the `.cache` directory. Run with `-i -v [version_tag]` to (re)install a specific version.
- builds the project with Maven (uses `mvnw`)
- deploys the plugin (i.e. copies it into the directory `<RH_HOME>/plugins`)
- restart RESTHeart

You can check the log file with `tail -f restheart.log`

The full script options are:

```terminal
$ ./bin/rh.sh -h
Usage: rh.sh [-h] [-b] [-w] [-i [-v version]] [-p http_port] [-o restheart options] [--no-color] [command]

Helper script to Build, Watch and Deploy the plugin, automatically restarting RESTHeart. It also installs RESTHeart.

Commands:

b, build   Build and deploy the plugin, restarting RESTHeart (default)
r, run     start (or restarts) RESTHeart
k, kill    Kill RESTHeart
w, watch   Watch sources and build and deploy the plugin on changes, restarting RESTHeart

Available options:

-h, --help          Print this help and exit
-i, --install       Force reinstalling RESTHeart
-v, --version       RESTHeart version tag to install (default is latest)
-p, --port          HTTP port to use (default is 8080)
-o, --options       pass options to RESTHeart
--no-color          Disable colored output

Examples:

./bin/rh.sh build                                 build the plugin, deploy it and run RESTHeart with it
./bin/rh.sh                                       like 'build'
./bin/rh.sh start                                 start or restart RESTHeart
./bin/rh.sh watch                                 automatically re-run on code changes
./bin/rh.sh --port 9090 -o "-s"                   run on HTTP port 9090 with standalone configuration (-s)
./bin/rh.sh -o "-c"                               print RESTHeart effective configuration
./bin/rh.sh -i -v 7.1.0 run                       Force reinstalling RESHeart version 7.1.0, then run
RHO='/logging/log-level->"debug"' ./bin/rh.sh     run passing the RHO env var to override configuration


All commands automatically download and install RESTHeart if needed.
```

## Get notified when RESTHeart restarts

The following command can be used to get notified on OSX when RESTHeart is restarted by `bin/rh.sh watch`.

```bash
& tail -f restheart.log | awk '/RESTHeart stopped/ { system("./bin/notify_osx.sh RESTHeart stopped") } /RESTHeart started/ { system("./bin/notify_osx.sh RESTHeart started") } /.*/'
```

If you are on Linux, you can tweak the command (`notify_osx.sh` is specific for OSX). Have a look at [this article](https://superuser.com/questions/31917/is-there-a-way-to-show-notification-from-bash-script-in-ubuntu) for some ideas.

## MongoDB

You can use docker-compose to run MongoDB

```bash
$ docker-compose up -d
```

> docker-compose runs MongoDB as a single instance replica set. This is required for transactions and change streams to work.

### Init MongoDB

The script `docker/docker-entrypoint-initdb.d/initdb.js` is executed by the mongo shell in the MongoDB container and allows initializing MongoDB, for instance creating test data.

## Kill RESTHeart

Use the command `./bin/rh.sh kill` to kill the instance of RESTHeart.

## Watch: automatic rebuilding and restarting

You can use the command `bin/rh watch`, to have the project automatically rebuilt, and RESTHeart automatically restarted whenever a source or configuration file changes.

```bash
$ ./bin/rh watch
```

Or

```bash
$ ./bin/rh watch -p microd
```

## Get building notifications on OSX

The following command can be used to get notified on OSX when about building events triggered by the script `bin/watch.sh`

```bash
$ ./bin/watch.sh -p restheart | awk '/BUILD SUCCESS/ { system("./bin/notify_osx.sh RESTHeart build:success") } /BUILD FAILURE/ { system("./bin/notify_osx.sh RESTHeart build:failure") } /Building / { system("./bin/notify_osx.sh RESTHeart building...") } /.*/'
```

## Hot Code Replace

The script `bin/rh.sh` runs RESTHeart with the debugger enabled, that allows some *Hot Code Replace*.

## RESTHeart Configuration

The default configuration is used. The environment variable `RHO` can be used to override the configuration. See [Modify the configuration with the RHO env var](https://restheart.org/docs/configuration#modify-the-configuration-with-the-rho-env-var)

## Dependencies

The dependencies jars are copied by the `maven-dependency-plugin` to the `target/lib` directory. Those jars are copied to the RESTHeart's `plugins` directory to add them to to the classpath by the script `bin/restart.sh`.

> When you add a dependency, you must restart the RESTHeart container.

### Avoid duplicate jars

`restheart.jar` embeds several jars. You should avoid adding to the classpath a jar that is already included in it.

You can avoid a dependency to be added to the classpath by specifying the scope `provided` in the pom dependency. For instance, the `restheart-commons` dependency has the scope `provided` because it is already embedded in `restheart.jar`:

```xml
<dependency>
    <groupId>org.restheart</groupId>
    <artifactId>restheart-commons</artifactId>
    <version>7.2</version>
    <scope>provided</scope>
</dependency>
```

Other libraries that are embedded in `restheart.jar` are the MongoDB driver and Unirest http library.

You can check which libraries are embedded in `restheart.jar` as follows:

```bash
$ git clone https://github.com/SoftInstigate/restheart.git && cd restheart
$ mvn dependency:tree -Dscope=compile
```

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

## Build native image

RESTHeart supports native images builds with GraalVM.

See [Deploy Java Plugins on RESTHeart native](https://restheart.org/docs/plugins/deploy/#deploy-java-plugins-on-restheart-native) documentation page for more information.

### Requirements

Building RESTHeart with your plugin as a native image requires the GraalVM and its `native-image` tool.

Check [Install the GraalVM](https://restheart.org/docs/graalvm/#install-the-graalvm) documentation page for more information on how to install them.

Also install `native-image` and `GraalVM.js` (the latter required from GraalVM v22.2.r17)

```
$ gu install native-image
$ gu install js
```

### Build the native image

The `pom.xml` defines the `native` profile. To build your RESTHeart embedding your plugin run:

```bash
$ ./mvnw clean package -Pnative
```

> note: native image build takes about 10 minutes!

The binary executable is `./target/restheart-plugin-skeleton`

Run it with:

```bash
$ mkdir target/plugins # the polyglot deployer needs the plugins directory
$ ./target/restheart-plugin-skeleton etc/restheart.yml -e etc/dev.properties
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
$ curl localhost:8080/srv
{"message":"Hello World!sss ss","rnd":"njXZksfKFW"}%%
```

**HTTP Shell**

> download HTTP Shell from [GitHub](https://github.com/SoftInstigate/http-shell/releases)

```bash
> h set url :8080
> h get /srv
```
