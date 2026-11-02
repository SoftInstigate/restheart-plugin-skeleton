# JavaScript and TypeScript plugins

RESTHeart runs plugins written in JavaScript or TypeScript, with no Java, on GraalVM and in the native image. This directory is one such plugin, written in TypeScript on the `restheart:sdk` module (RESTHeart 9.14.0 or later).

| source | what it is |
|---|---|
| `src/hello.mts` | a service at `/js/hello`, reading `req.query` and its configuration |
| `src/hello-interceptor.mts` | an interceptor that changes the response of the Java `helloWorldService` of this skeleton |

`tsc` compiles each `src/*.mts` to the `.mjs` file that `package.json` lists in `rh:services` and `rh:interceptors`. RESTHeart deploys the `.mjs` files and does not transpile.

The SDK is documented at [restheart.org/docs/framework/javascript-plugins](https://restheart.org/docs/framework/javascript-plugins).
