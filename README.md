# RESTHeart Plugin Skeleton

This repository provides a skeleton project for developing plugins for RESTHeart, a REST API platform for MongoDB.

Documentation for plugins development is available at [https://restheart.org/docs/plugins/overview/](https://restheart.org/docs/plugins/overview/).

Check also the [RESTHeart Greetings Services Tutorial](https://restheart.org/docs/plugins/tutorial)

---

## Requirements

- **Java 24 (or GraalVM 24)**: Required to compile and run the plugin.
- **Docker**: Used to containerize and run RESTHeart.

Note: for RESTHeart 8.0.0 to 8.9.x, use Java 21 (or GraalVM 21)

---

## Quick Start

### Option 1: Use the RESTHeart CLI (Recommended)

🚀 The [RESTHeart CLI](https://github.com/SoftInstigate/restheart-cli/tree/master) provides automatic rebuilding and hot-reloading during development.

Follow the [Usage Guide](https://github.com/SoftInstigate/restheart-cli/blob/master/usage-guide.md) to set up a continuous development workflow.

### Option 2: Build and Run with Docker

1. **Clone and navigate:**
   ```bash
   git clone --depth 1 git@github.com:SoftInstigate/restheart-plugin-skeleton.git
   cd restheart-plugin-skeleton
   ```

2. **Build (choose Maven or Gradle):**
   ```bash
   # Maven
   ./mvnw clean package
   
   # Gradle
   ./gradlew clean build
   ```
   
   Both produce identical outputs in the `target/` directory.

3. **Run with Docker:**
   ```bash
   docker run --pull=always --name restheart --rm -p "8080:8080" \
     -v ./target:/opt/restheart/plugins/custom \
     softinstigate/restheart -s
   ```
   
   > **Note:** The `-s` flag runs in **standalone mode** (no MongoDB). Remove it to enable MongoDB-dependent plugins.

4. **Test the service:**
   ```bash
   curl localhost:8080/srv
   {"message":"Hello World!","rnd":"njXZksfKFW"}
   ```

---

## Build Systems: Maven vs Gradle

Both build systems are fully supported and produce identical outputs:

| Feature                    | Maven                              | Gradle                               |
| -------------------------- | ---------------------------------- | ------------------------------------ |
| Build Command              | `./mvnw clean package`             | `./gradlew clean build`              |
| Native Image               | `./mvnw package -Pnative`          | `./gradlew build -Pnative`           |
| Profile Activation         | `-Psecurity,mongodb`               | `-Psecurity -Pmongodb`               |
| Build Speed                | Moderate                           | Faster (incremental, daemon)         |

**Choose based on your preference** - both work equally well for plugin development.

---

## Working with MongoDB

To run RESTHeart with MongoDB:

1. **Start MongoDB:**
   ```bash
   docker run -d --name mongodb -p 27017:27017 mongo --replSet=rs0
   docker exec mongodb mongosh --quiet --eval "rs.initiate()"
   ```

2. **Build with MongoDB profile:**
   ```bash
   # Maven
   ./mvnw clean package -Pmongodb
   
   # Gradle
   ./gradlew clean build -Pmongodb
   ```

3. **Run RESTHeart (without -s flag):**
   ```bash
   docker run --name restheart --rm -p "8080:8080" \
     -v ./target:/opt/restheart/plugins/custom \
     softinstigate/restheart
   ```

4. **Test:**
   ```bash
   curl -u admin:secret localhost:8080/users
   ```

⚠️ **Warning:** This setup is insecure - for development/testing only.

---

## Available Profiles

Profiles add RESTHeart modules to your build:

| Profile                  | Description                                  | Maven Syntax         | Gradle Syntax        |
| ------------------------ | -------------------------------------------- | -------------------- | -------------------- |
| `native`                 | Build native executable with GraalVM         | `-Pnative`           | `-Pnative`           |
| `security`               | Add authentication and authorization         | `-Psecurity`         | `-Psecurity`         |
| `mongodb`                | Add MongoDB REST API support                 | `-Pmongodb`          | `-Pmongodb`          |
| `graphql`                | Add GraphQL API support                      | `-Pgraphql`          | `-Pgraphql`          |
| `mongoclient-provider`   | Add MongoDB client provider                  | `-Pmongoclient-provider` | `-Pmongoclient-provider` |
| `metrics`                | Add monitoring and metrics                   | `-Pmetrics`          | `-Pmetrics`          |
| `all-restheart-plugins`  | Include all above modules (except native)    | `-Pall-restheart-plugins` | `-Pall-restheart-plugins` |

### Examples

```bash
# Maven: Native build with security and MongoDB
./mvnw clean package -Pnative,security,mongodb

# Gradle: Native build with security and MongoDB
./gradlew clean build -Pnative -Psecurity -Pmongodb

# Maven: All modules
./mvnw clean package -Pall-restheart-plugins

# Gradle: All modules
./gradlew clean build -Pall-restheart-plugins
```

### Common Scenarios

| Scenario                      | Maven Command                                | Gradle Command                               |
| ----------------------------- | -------------------------------------------- | -------------------------------------------- |
| Standalone demo               | `./mvnw clean package`                       | `./gradlew clean build`                      |
| MongoDB development           | `./mvnw clean package -Pmongodb`             | `./gradlew clean build -Pmongodb`            |
| Secured MongoDB API           | `./mvnw clean package -Psecurity,mongodb`    | `./gradlew clean build -Psecurity -Pmongodb` |
| GraphQL over MongoDB          | `./mvnw clean package -Pgraphql,mongodb`     | `./gradlew clean build -Pgraphql -Pmongodb`  |
| All modules                   | `./mvnw clean package -Pall-restheart-plugins` | `./gradlew clean build -Pall-restheart-plugins` |

---

## Building Native Images

Native images provide faster startup and lower memory usage.

### Requirements

Install GraalVM using [SDKMAN](https://sdkman.io/):
```bash
sdk install java 24.0.2-graalce
sdk use java 24.0.2-graalce
```

### Build Commands

**Quick build** (faster, default):
```bash
# Maven
./mvnw clean package -Pnative

# Gradle
./gradlew clean build -Pnative
```

**Full optimization** (slower build, faster runtime):
```bash
# Maven
./mvnw clean package -Pnative -Dnative.quickBuild=false

# Gradle
./gradlew clean build -Pnative -Pnative.quickBuild=false
```

**Custom garbage collector** (G1 on Linux, serial elsewhere):
```bash
# Maven
./mvnw clean package -Pnative -Dnative.gc=--gc=G1

# Gradle
./gradlew clean build -Pnative -Pnative.gc=--gc=G1
```

### Run Native Executable

```bash
# Basic run
./target/restheart-plugin-skeleton

# With configuration override
RHO="/fullAuthorizer/enabled->true" ./target/restheart-plugin-skeleton
```

**Output structure:**
```
target/
├── restheart-plugin-skeleton.jar      # Plugin JAR
├── restheart-plugin-skeleton          # Native executable (with -Pnative)
└── lib/                               # Runtime dependencies
```

---

## Configuration

### Runtime Configuration with RHO

Override settings without rebuilding using the `RHO` environment variable:

```bash
docker run --name restheart --rm \
  -e RHO="/http-listener/host->'0.0.0.0';/helloWorldService/message->'Ciao Mondo!'" \
  -p "8080:8080" \
  -v ./target:/opt/restheart/plugins/custom \
  softinstigate/restheart -s
```

Test:
```bash
curl localhost:8080/srv
{"message":"Ciao Mondo!","rnd":"rhyXFHOQUA"}
```

See [RESTHeart Configuration](https://restheart.org/docs/configuration#change-the-configuration-in-docker-container) for more details.

---

## Dependencies

### Adding Dependencies

Dependencies are automatically copied to `target/lib/` and loaded by RESTHeart.

**Maven** (`pom.xml`):
```xml
<dependency>
    <groupId>com.example</groupId>
    <artifactId>my-library</artifactId>
    <version>1.0.0</version>
</dependency>
```

**Gradle** (`build.gradle`):
```groovy
dependencies {
    implementation 'com.example:my-library:1.0.0'
}
```

### Avoiding Duplicate JARs

RESTHeart bundles many libraries. Use `provided` scope for dependencies already included:

```xml
<dependency>
    <groupId>org.restheart</groupId>
    <artifactId>restheart-commons</artifactId>
    <version>${restheart.version}</version>
    <scope>provided</scope>
</dependency>
```

To see what's included:
```bash
git clone https://github.com/SoftInstigate/restheart.git
cd restheart
mvn dependency:tree -Dscope=compile
```

---

## Troubleshooting

### Build Issues

**Gradle-specific:**
```bash
# Clean build without cache
./gradlew clean build --no-build-cache

# Stop and restart daemon
./gradlew --stop
./gradlew clean build
```

### Native Image Issues

1. **Verify GraalVM:**
   ```bash
   java -version  # Should show GraalVM
   which native-image
   native-image --version
   ```

2. **Build with verbose output:**
   ```bash
   # Maven
   ./mvnw package -Pnative -X
   
   # Gradle
   ./gradlew build -Pnative --info
   ```

### Debugging

**View Docker logs:**
```bash
docker logs -f restheart
```

**Common issues:**
- `405 Method Not Allowed`: Check HTTP method handling in your service class
- Missing `OPTIONS` handler: Add `handleOptions(req)` for CORS support

---

## Gradle-Specific Features

### Performance Benefits

Gradle provides faster builds through:
- **Incremental compilation**: Only changed files are recompiled
- **Build daemon**: JVM stays warm between builds (1-3s vs 5-10s with Maven)
- **Parallel execution**: Independent tasks run concurrently
- **Build cache**: Reuses outputs from previous builds

### Gradle Tasks

```bash
./gradlew tasks              # List all tasks
./gradlew clean              # Delete build outputs
./gradlew build              # Full build
./gradlew jar                # Create JAR only
./gradlew nativeCompile      # Build native image
```

### Configuration Properties

Edit `gradle.properties` to customize:
```properties
# RESTHeart version
restheart.version=[8.12.0,8.1000.0)

# Native image settings
native.gc=--gc=serial
native.quickBuild=true
```

---

## Next Steps

- 📖 Read the [RESTHeart Plugins Documentation](https://restheart.org/docs/plugins/overview/)
- 🎓 Follow the [Greetings Services Tutorial](https://restheart.org/docs/plugins/tutorial)
- 🔧 Explore the [RESTHeart CLI](https://github.com/SoftInstigate/restheart-cli) for hot-reloading
- 🚀 Check [Deployment Guide](https://restheart.org/docs/plugins/deploy) for production tips
