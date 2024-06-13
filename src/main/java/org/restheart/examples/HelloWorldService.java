/*
 * Copyright 2020 SoftInstigate srl
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.restheart.examples;

/**
 *
 * @author Andrea Di Cesare <andrea@softinstigate.com>
 */

import java.util.Map;

import org.apache.commons.lang3.RandomStringUtils;
import org.restheart.exchange.JsonRequest;
import org.restheart.exchange.JsonResponse;
import org.restheart.plugins.Inject;
import org.restheart.plugins.JsonService;
import org.restheart.plugins.OnInit;
import org.restheart.plugins.RegisterPlugin;
import static org.restheart.utils.GsonUtils.object;
import org.restheart.utils.HttpStatus;

/**
 * Just another Hello World program.
 *
 * @author Andrea Di Cesare <andrea@softinstigate.com>
 */
@RegisterPlugin(name = "helloWorldService",
                description = "just another Hello World program",
                defaultURI = "/srv",
                blocking = false)
public class HelloWorldService implements JsonService {
    private String message;

    @Inject("config")
    Map<String, Object> args;

    @OnInit
    public void onInit() {
        this.message = argOrDefault(this.args, "message", "Hello World!");
    }

    @Override
    public void handle(JsonRequest req, JsonResponse res) {
        switch(req.getMethod()) {
            case GET -> res.setContent(object()
                .put("message", this.message)
                .put("rnd", RandomStringUtils.randomAlphabetic(10)));
            case OPTIONS -> handleOptions(req);
            default -> res.setStatusCode(HttpStatus.SC_METHOD_NOT_ALLOWED);
        }
    }
}
