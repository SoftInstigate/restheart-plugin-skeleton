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

import org.restheart.exchange.JsonRequest;
import org.restheart.exchange.JsonResponse;
import org.restheart.plugins.JsonService;
import org.restheart.plugins.RegisterPlugin;
import org.restheart.utils.HttpStatus;
// RandomStringUtils is from Apache commons-lang3 library
// This is an external dependency i.e. it is not provided by restheart.jar,
// and thus it must be added to the classpath for the service to work.
// All (not provided) dependenies are copied to target/lib by the
// maven-dependency-plugin
// and then copied to the plugins directory to add them to the classpath
// by the script restart.sh
// See https://github.com/SoftInstigate/restheart-plugin-skeleton/blob/master/README.md#dependencies
import org.apache.commons.lang3.RandomStringUtils;
import static org.restheart.utils.GsonUtils.object;

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
    @Override
    public void handle(JsonRequest req, JsonResponse res) {
        switch(req.getMethod()) {
            case GET -> res.setContent(object()
                .put("message", "Hello World!")
                .put("rnd", RandomStringUtils.randomAlphabetic(10)));
            case OPTIONS -> handleOptions(req);
            default -> res.setStatusCode(HttpStatus.SC_METHOD_NOT_ALLOWED);
        }
    }
}
