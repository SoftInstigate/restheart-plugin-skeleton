# RESTHeart Plugin Skeleton

This repository provides a skeleton project for RESTHeart Plugins.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

Check also the [RESTHeart Greetings Services Tutorial
](https://restheart.org/docs/plugins/tutorial)

## Requirements

- Java 21+ (or GraalVM 21+)
- Docker

## Quick start

```bash
$ git clone --depth 1 git@github.com:SoftInstigate/restheart-plugin-skeleton.git && cd restheart-plugin-skeleton
$ ./mvnw clean package && docker run --name restheart --rm -p "8080:8080" -v ./target:/opt/restheart/plugins/custom softinstigate/restheart -s
```

The `-s` option (standalone mode) disables the plugins depending on MongoDB; this avoids to start MongoDB for running it.

The project skeleton defines a dummy *Service* bound at `/srv`:

With curl

```bash
$ curl localhost:8080/srv
{"message":"Hello World!","rnd":"njXZksfKFW"}%
```

with httpie

```bash
$ http -b :8080/srv
{
    "message": "Hello World!",
    "rnd": "KvQGBwsPBp"
}
```

## Run RESTHeart with MongoDB

**WARNING**: **This setup is insecure and should be only used for developing or testing purposes.**

This setup only needs to be completed once. Follow these steps:

1) Launch a MongoDB container:

```bash
$ docker run -d --name mongodb -p 27017:27017 mongo --replSet=rs0
```

2) Initialize MongoDB as a Single Node Replica Set

```bash
$ docker exec mongodb mongosh --quiet --eval "rs.initiate()"
```

3) Build and Launch RESTHeart Container

```bash
$ ./mvnw clean package && docker run --name restheart --rm -p "8080:8080" -v ./target:/opt/restheart/plugins/custom softinstigate/restheart
```

NOTE: we don't specify the `-s` option, so RESTHeart connects to MongoDB and provides the Data APIs.

Test a simple GET /users request. The `admin` user is created automatically.

With curl

```bash
$ curl -u admin:secret localhost:8080/users
[{"_id": "admin", "roles": ["admin"]}]%
```

With httpie:

```bash
$ http -a admin:secret :8080/users
```

You might want to check the [REST API Tutorial](https://restheart.org/docs/mongodb-rest/tutorial) and the [GraphQL Tutorial](https://restheart.org/docs/mongodb-graphql/tutorial)

### Init MongoDB

The script `docker/docker-entrypoint-initdb.d/initdb.js` is executed by the mongo shell in the MongoDB container and allows initializing MongoDB, for instance creating test data.

## RESTHeart Configuration

The default configuration is used. The environment variable `RHO` can be used to override the configuration. See [Change the configuration in Docker container](https://restheart.org/docs/configuration#change-the-configuration-in-docker-container)

Here an example to define the dummy *Service* message:

```bash
$ docker run --name restheart --rm -e RHO="/http-listener/host->'0.0.0.0';/mclient/connection-string->'mongodb://host.docker.internal';/helloWorldService/message->'Ciao Mondo!'" -p "8080:8080" -v ./target:/opt/restheart/plugins/custom softinstigate/restheart -s
```

Here we override the configuration option `/helloWorldService/message` with `Ciao Mondo!`. The other overrides are needed: when defining your RHO variable always set` /http-listener/host→"0.0.0.0"` and your` /mclient/connection-string`.

```bash
$ curl localhost:8080/srv
{"message":"Ciao Mondo!","rnd":"rhyXFHOQUA"}%
```

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
    <version>8.0</version>
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

We suggest to install GraalVM with [sdk](https://sdkman.io/)

```
$ sdk install java 21.0.3-graal
```

### Build the native image

The `pom.xml` defines the `native` profile. To build your RESTHeart embedding your plugin run:

```bash
$ ./mvnw clean package -Pnative
```

**NOTE:** native image build takes few minutes!

The binary executable is `./target/restheart-plugin-skeleton`

Run it with:

```bash
$ RHO="/fullAuthorizer/enabled->true" target/restheart-plugin-skeleton
```

**NOTE:** The native image is configured to build with custom plugins and the `restheart-core` and `restheart-polyglot` modules. The default RESTHeart plugins (`restheart-security`, `restheart-mongodb`, `restheart-graphql`, and `restheart-mongoclient-provider`) are currently commented out in the `pom.xml`. To include these plugins in the native image, simply uncomment their dependencies in the `native` profile section of the `pom.xml`.

The `RHO` environment variable enables the `fullAuthorizer`. Since `restheart-security` is excluded by default from this native image, any requests are authorized by default when this variable is set.

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

HTTP Shell provides developers with a modern alternative to HTTP clients for interacting with APIs.

> download HTTP Shell from [GitHub](https://github.com/SoftInstigate/http-shell/releases)

```bash
> h set url :8080
> h get /srv
```
