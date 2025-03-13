# RESTHeart Plugin Skeleton

This repository provides a skeleton project for developing plugins for RESTHeart, a REST API platform for MongoDB.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

Check also the [RESTHeart Greetings Services Tutorial](https://restheart.org/docs/plugins/tutorial)

---

## Requirements

- **Java 21+ (or GraalVM 21+)**: Required to compile and run the plugin.
- **Docker**: Used to containerize and run RESTHeart.

---

## Quick Start

### Use the RESTHeart command line interface

🚀 To run and develop this project you can now use the new [RESTHeart command line interface](https://github.com/SoftInstigate/restheart-cli/tree/master). It provides a convenient interface for watching for code changes and automatically rebuilding/redeploying RESTHeart plugins.

After you have installed the cli, follow its [Usage Guide](https://github.com/SoftInstigate/restheart-cli/blob/master/usage-guide.md). It explains how to start from this plugin skeleton to create a __continuous development process__.

### Run with Docker

Follow these steps if you prefer to set up and run the project with docker:

1. Clone the repository:
   ```bash
   $ git clone --depth 1 git@github.com:SoftInstigate/restheart-plugin-skeleton.git
   ```
2. Navigate to the project directory:
   ```bash
   $ cd restheart-plugin-skeleton
   ```
3. Build and run the container:
   ```bash
   $ ./mvnw clean package && docker run --pull=always --name restheart --rm -p "8080:8080" -v ./target:/opt/restheart/plugins/custom softinstigate/restheart -s
   ```

> **Note:** The `-s` option (**standalone mode**) disables MongoDB-dependent plugins. Use this option if you do not intend to connect to a MongoDB instance during runtime.

Test the service using:

With curl:
```bash
$ curl localhost:8080/srv
{"message":"Hello World!","rnd":"njXZksfKFW"}%
```

With httpie:
```bash
$ http -b :8080/srv
{
    "message": "Hello World!",
    "rnd": "KvQGBwsPBp"
}
```

---

## Run RESTHeart with MongoDB

⚠️ **Warning:** This setup is insecure and should only be used for development or testing.

To run RESTHeart with MongoDB, follow these steps:

1. Launch a MongoDB container:
   ```bash
   $ docker run -d --name mongodb -p 27017:27017 mongo --replSet=rs0
   ```
2. Initialize MongoDB as a Single Node Replica Set:
   ```bash
   $ docker exec mongodb mongosh --quiet --eval "rs.initiate()"
   ```
3. Build and run the RESTHeart container:
   ```bash
   $ ./mvnw clean package && docker run --name restheart --rm -p "8080:8080" -v ./target:/opt/restheart/plugins/custom softinstigate/restheart
   ```

> **Note:** The `-s` option is not used here to enable MongoDB-dependent plugins.

Test a simple GET request:
```bash
$ curl -u admin:secret localhost:8080/users
```

For more details, check the [REST API Tutorial](https://restheart.org/docs/mongodb-rest/tutorial) and the [GraphQL Tutorial](https://restheart.org/docs/mongodb-graphql/tutorial).

---

## RESTHeart Configuration

The default configuration is used. The environment variable `RHO` can be used to override the configuration. See [Change the configuration in Docker container](https://restheart.org/docs/configuration#change-the-configuration-in-docker-container)

Example:
```bash
$ docker run --name restheart --rm     -e RHO="/http-listener/host->'0.0.0.0';/mclient/connection-string->'mongodb://host.docker.internal';/helloWorldService/message->'Ciao Mondo!'"     -p "8080:8080"     -v ./target:/opt/restheart/plugins/custom     softinstigate/restheart -s
```

Here, the `RHO` variable overrides:
- `/http-listener/host`: Sets the host to `0.0.0.0`.
- `/mclient/connection-string`: Specifies the MongoDB connection string.
- `/helloWorldService/message`: Changes the default service message to "Ciao Mondo!".

```bash
$ curl localhost:8080/srv
{"message":"Ciao Mondo!","rnd":"rhyXFHOQUA"}%
```

---

## Dependencies

Dependencies are managed using Maven. By default, jars are copied to the `target/lib` directory by the `maven-dependency-plugin`. These jars are automatically added to the classpath by RESTHeart.

### Avoid Duplicate JARs

RESTHeart includes several libraries by default. To avoid conflicts:
- Use the `provided` scope for dependencies already included in RESTHeart.

Example:
```xml
<dependency>
    <groupId>org.restheart</groupId>
    <artifactId>restheart-commons</artifactId>
    <version>${restheart.version}</version>
    <scope>provided</scope>
</dependency>
```

To list included libraries:
```bash
$ git clone https://github.com/SoftInstigate/restheart.git && cd restheart
$ mvn dependency:tree -Dscope=compile
```

---

## Build Native Image

RESTHeart supports building native images with GraalVM for optimized startup time and memory usage.

### Requirements
- Install GraalVM using [sdkman](https://sdkman.io/):
  ```bash
  $ sdk install java 21.0.3-graal
  ```

### Build and Run Native Image

1. Build the native image:
   ```bash
   $ ./mvnw clean package -Pnative
   ```
2. Run the binary:
   ```bash
   $ RHO="/fullAuthorizer/enabled->true" target/restheart-plugin-skeleton
   ```

For more details, check [Deploy Java Plugins on RESTHeart native](https://restheart.org/docs/plugins/deploy#deploy-java-plugins-on-restheart-native).

---

## Maven Profiles

### Available Profiles

| Profile ID             | Description                                                                       |
| ---------------------- | --------------------------------------------------------------------------------- |
| `native`               | Builds a native image using GraalVM with custom plugins.                          |
| `security`             | Includes the `restheart-security` module for advanced security.                   |
| `mongodb`              | Adds MongoDB support with the `restheart-mongodb` module.                         |
| `graphql`              | Enables GraphQL APIs using the `restheart-graphql` module.                        |
| `mongoclient-provider` | Provides a MongoClient provider with the `restheart-mongoclient-provider` module. |
| `metrics`              | Adds monitoring capabilities with the `restheart-metrics` module.                 |

### Using Maven Profiles

Activate a profile with the `-P` option:
```bash
$ ./mvnw clean package -Psecurity
```

Combine profiles as needed:
```bash
$ ./mvnw clean package -Psecurity,mongodb
```

For more details, refer to the `pom.xml` file.
