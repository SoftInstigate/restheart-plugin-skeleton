import { defineInterceptor } from "restheart:sdk";

// A JavaScript interceptor on the Java service of this skeleton: helloWorldService is a
// JsonService, so a json interceptor sees its requests and can change its response.
export default defineInterceptor({
    name: "helloJsInterceptor",
    description: "adds a field to the response of the Java helloWorldService",
    interceptPoint: "RESPONSE",
    contentKind: "json",

    handle(req, res) {
        res.content = { ...(res.content as object), interceptedBy: "helloJsInterceptor" };
    },

    resolve(req) {
        return req.isHandledBy("helloWorldService") && req.isGet();
    },
});
