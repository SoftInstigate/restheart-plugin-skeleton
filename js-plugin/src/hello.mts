import { defineService, config, logger } from "restheart:sdk";

// GET /js/hello?name=Andrea answers { "message": "Hello Andrea!" }.
// The message comes from restheart.yml, by plugin name:
//
//   helloJsService:
//     message: Ciao
export default defineService({
    name: "helloJsService",
    description: "just another Hello World, in TypeScript",
    uri: "/js/hello",
    matchPolicy: "EXACT",
    contentKind: "json",

    handle(req, res) {
        if (!req.isGet()) {
            res.statusCode = 405;
            return;
        }

        const greeting = (config.message as string | undefined) ?? "Hello";
        const name = req.query.name ?? "World";

        logger.debug("greeting {}", name);

        res.json({ message: `${greeting} ${name}!` });
    },
});
