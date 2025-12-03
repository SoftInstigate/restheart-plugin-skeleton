# AI Coding Agent Instructions for restheart-plugin-skeleton

These instructions help AI agents work productively in this repo.

## Big Picture
- Purpose: Build Java plugins for RESTHeart (MongoDB REST/GraphQL platform).
- Output: A plugin JAR plus its runtime deps under `target/` so RESTHeart can load it.
- Two run modes:
  - Docker: mount `target` as plugin dir into official `softinstigate/restheart` image.
  - Native: build a standalone binary with GraalVM via Maven `native` profile.

## Code Layout & Key Files
- `src/main/java/org/restheart/examples/HelloWorldService.java`: Minimal JSON service example.
  - Registers via `@RegisterPlugin(name, description, defaultURI, blocking)` and implements `JsonService#handle(JsonRequest, JsonResponse)`.
  - Accepts config via `@Inject("config") Map<String,Object>` and `@OnInit` reads `message`.
  - Pattern: `GET` → JSON body using `GsonUtils.object()`, `OPTIONS` → `handleOptions`, others → `405`.
- `pom.xml`: Java 21, RESTHeart version `${restheart.version}`, plugin copy-deps, optional profiles.
- `README.md`: Canonical usage, Docker, MongoDB, native image, and RHO config examples.
- Runtime classpath: External deps copied into `target/lib` by `maven-dependency-plugin`.

## Build & Run
- Build plugin:
  - `./mvnw clean package`
- Run with RESTHeart Docker (standalone):
  - `./mvnw clean package && docker run --pull=always --name restheart --rm -p "8080:8080" -v ./target:/opt/restheart/plugins/custom softinstigate/restheart -s`
- Run with MongoDB (dev-only, insecure):
  - `docker run -d --name mongodb -p 27017:27017 mongo --replSet=rs0`
  - `docker exec mongodb mongosh --quiet --eval "rs.initiate()"`
  - `./mvnw clean package && docker run --name restheart --rm -p "8080:8080" -v ./target:/opt/restheart/plugins/custom softinstigate/restheart`
- Test:
  - `curl localhost:8080/srv`
  - or `http -b :8080/srv`

## Native Image Workflow (GraalVM)
- Install GraalVM 21 with sdkman: `sdk install java 21.0.3-graal`.
- Build: `./mvnw clean package -Pnative`.
- Run: `RHO="/fullAuthorizer/enabled->true" target/restheart-plugin-skeleton`.

## Config Conventions (RHO)
- Override settings via `RHO` env var when running RESTHeart:
  - Example: `docker run -e RHO="/http-listener/host->'0.0.0.0';/helloWorldService/message->'Ciao Mondo!'" ...`
- The example service reads `message` from `config` in `@OnInit`.

## Dependency Guidance
- Avoid duplicate libs: RESTHeart includes many libs by default.
- Use `<scope>provided</scope>` for RESTHeart-provided artifacts (e.g., `restheart-commons`).
- External deps needed at runtime are copied into `target/lib` automatically.

## Maven Profiles
- `native`: adds RESTHeart modules and native build tools; produces binary.
- `security`, `mongodb`, `graphql`, `mongoclient-provider`, `metrics`: opt-in RESTHeart modules.
- Activate: `./mvnw clean package -Psecurity` or combine: `-Psecurity,mongodb`.

## Patterns to Follow When Adding Plugins
- Create a class implementing `JsonService` (or other RESTHeart service interfaces).
- Annotate with `@RegisterPlugin` to expose at a URI.
- Use `@Inject("config")` + `@OnInit` for startup config.
- In `handle(...)`: switch on HTTP method; return JSON via `GsonUtils.object()`; call `handleOptions(req)` to support CORS/OPTIONS.
- Keep business logic isolated; avoid static initialization that blocks native-image compilation.

## Helpful References
- Docs: https://restheart.org/docs/plugins/overview/ and tutorial links in `README.md`.
- CLI for dev loop (watch/redeploy): https://github.com/SoftInstigate/restheart-cli
