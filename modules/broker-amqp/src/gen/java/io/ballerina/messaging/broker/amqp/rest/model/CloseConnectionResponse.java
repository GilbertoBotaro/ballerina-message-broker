/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package io.ballerina.messaging.broker.amqp.rest.model;

import javax.validation.constraints.*;
import javax.validation.Valid;


import io.swagger.annotations.*;
import java.util.Objects;
import com.fasterxml.jackson.annotation.JsonProperty;


public class CloseConnectionResponse {

    private @Valid Integer numberOfChannelsRegistered = null;

    /**
     * Response message with number of channels closed.
     **/
    public CloseConnectionResponse numberOfChannelsRegistered(Integer numberOfChannelsRegistered) {
        this.numberOfChannelsRegistered = numberOfChannelsRegistered;
        return this;
    }


    @ApiModelProperty(required = true, value = "Response message with number of channels closed.")
    @JsonProperty("numberOfChannelsRegistered")
    @NotNull
    public Integer getNumberOfChannelsRegistered() {
        return numberOfChannelsRegistered;
    }
    public void setNumberOfChannelsRegistered(Integer numberOfChannelsRegistered) {
        this.numberOfChannelsRegistered = numberOfChannelsRegistered;
    }


    @Override
    public boolean equals(java.lang.Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        CloseConnectionResponse closeConnectionResponse = (CloseConnectionResponse) o;
        return Objects.equals(numberOfChannelsRegistered, closeConnectionResponse.numberOfChannelsRegistered);
    }

    @Override
    public int hashCode() {
        return Objects.hash(numberOfChannelsRegistered);
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("class CloseConnectionResponse {\n");

        sb.append("    numberOfChannelsRegistered: ").append(toIndentedString(numberOfChannelsRegistered)).append("\n");
        sb.append("}");
        return sb.toString();
    }

    /**
     * Convert the given object to string with each line indented by 4 spaces
     * (except the first line).
     */
    private String toIndentedString(java.lang.Object o) {
        if (o == null) {
            return "null";
        }
        return o.toString().replace("\n", "\n    ");
    }
}
