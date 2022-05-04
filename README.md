# RESTHeart Plugin Skeleton Project

This repository provides a skeleton project to build RESTHeart Plugins.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

## Requirements

- Java 17+
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

Use the script `./bin/restart.sh` to start the latest release of RESTHeart in development mode, i.e. enabled for debugging on port 4000

```bash
$ ./mvnw clean package
$ ./bin/restart.sh -p restheart
```

> the script automatically deploys the plugin to RESTHeart

> the script automatically downloads RESTHeart in the `.cache` directory. Delete `.cache` and rerun the script to update RESTHeart to latest release.

You can check the log file with `tail -f restheart.log`

> log file path is set in `etc/dev.properties`

## Get notified when RESTHeart restarts

The following command can be used to get notified on OSX when RESTHeart is restarted by the script `bin/watch.sh`.

```bash
& tail -f restheart.log | awk '/RESTHeart stopped/ { system("./bin/notify_osx.sh RESTHeart stopped") } /RESTHeart started/ { system("./bin/notify_osx.sh RESTHeart started") } /.*/'
```

If you are on Linux, you can tweak the command (`notify_osx.sh` is specific for OSX). Have a look at [this article](https://superuser.com/questions/31917/is-there-a-way-to-show-notification-from-bash-script-in-ubuntu) for some ideas.

## microD profile

Use the profile `microd` to start RESTHeart without the MongoDB Service. We call this profile **microD**, because it is an effective runtime environment for micro-services.

```bash
$ mvn clean package
$ ./bin/restart.sh -p microd
```

## MongoDB

You can use docker-compose to run MongoDB

```bash
$ docker-compose up -d
```

> docker-compose runs MongoDB as a single instance replica set. This is required for transactions and change streams to work.

### Init MongoDB

The script `docker/docker-entrypoint-initdb.d/initdb.js` is executed by the mongo shell in the MongoDB container and allows initializing MongoDB, for instance creating test data.

## Stop RESTHeart

Use the script `./bin/stop.sh` to stop the instance of RESTHeart running in development mode.

## Watch: automatic rebuilding and restarting

You can use the script `bin/watch.sh`, to have the project automatically rebuilt, and RESTHeart automatically restarted whenever a source or configuration file changes.

```bash
$ ./bin/watch.sh -p restheart
```

Or

```bash
$ ./bin/watch.sh -p microd
```

## Get building notifications on OSX

The following command can be used to get notified on OSX when about building events triggered by the script `bin/watch.sh`

```bash
$ ./bin/watch.sh -p restheart | awk '/BUILD SUCCESS/ { system("./bin/notify_osx.sh RESTHeart build:success") } /BUILD FAILURE/ { system("./bin/notify_osx.sh RESTHeart build:failure") } /Building / { system("./bin/notify_osx.sh RESTHeart building...") } /.*/'
```

## Hot Code Replace

The script `bin/restart.sh` runs RESTHeart with the debugger enabled, that allows some *Hot Code Replace*.

For even quicker code modifications, you can stop the script `bin/watch.sh`, attach the debugger (on port 4000) to use the Hot Code Replace feature of your IDE.

## RESTHeart Configuration

The directory `etc` contains the configuration files that are used by the script `bin/restart.sh`.

When a configuration file is modified, the container RESTHeart is automatically restarted by the script `bin/watch.sh`.

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
    <version>6.3.0</version>
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

### Define the reflect-config.json for your plugins

Before building your plugin you need to define the native image reflection configuration.

You need to create in your plugin source project the file `src/main/resources/META-INF/native-image/<group-id>/<artifact-id>/reflect-config.json` and add an entry per each plugin.

The following entry is an example of [reflect-config.json](https://github.com/SoftInstigate/restheart-plugin-skeleton/blob/master/src/main/resources/META-INF/native-image/org.restheart/restheart-plugin-skeleton/reflect-config.json) required by the `HelloWorldService` included in the skeleton code:

```json
[
  {
    "name": "org.restheart.examples.HelloWorldService",
    "methods": [{ "name": "<init>", "parameterTypes": [] }]
  }
]
```

You need to specify the methods for:

1. the default Constructor (always)
2. the method annotated with `@InjectConfiguration` (if any)
3. the method annotated with `@InjectMongoClient` (if any)
4. the method annotated with `@InjectPluginsRegistry` (if any)

### Build the native image

The `pom.xml` defines the `native` profile. To build your RESTHeart embedding your plugin run:

```bash
$ ./mvnw clean package -Pnative
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
