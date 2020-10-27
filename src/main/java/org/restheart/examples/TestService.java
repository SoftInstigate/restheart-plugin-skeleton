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
package org.restheart.signup;

/**
 *
 * @author Andrea Di Cesare <andrea@softinstigate.com>
 */
import com.google.gson.JsonObject;
import org.restheart.exchange.JsonRequest;
import org.restheart.exchange.JsonResponse;
import org.restheart.plugins.JsonService;
import org.restheart.plugins.RegisterPlugin;
import org.restheart.utils.HttpStatus;

/**
 * verifeis a registered user
 *
 * it assumes that the user collection is 'restheart.users', the roles property
 * is 'roles' and the id of the user is "_id" (the default configuration values
 * of mongoRealAuthenticator)
 *
 * @author Andrea Di Cesare <andrea@softinstigate.com>
 */
@RegisterPlugin(name = "userVerifier",
        description = "verifies user",
        defaultURI = "/srv")
public class TestService implements JsonService {
    @Override
    public void handle(JsonRequest request, JsonResponse response)
            throws Exception {
        if (request.isOptions()) {
            handleOptions(request);
        } else if (request.isGet()) {
            var resp = new JsonObject();
            resp.addProperty("msg", "Hello World!");
            response.setContent(resp);
        } else {
            response.setStatusCode(HttpStatus.SC_NOT_IMPLEMENTED);
        }
    }
}