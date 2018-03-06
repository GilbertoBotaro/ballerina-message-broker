/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */

package io.ballerina.messaging.broker.core.store;

import java.util.ArrayList;
import java.util.List;

/**
 * Object to collect detach events relevant to a given queue. This contains the relevant detach message id list
 * and the post commit actions.
 */
public class QueueDetachEventList {

    private final List<Long> queueDetachRequests;

    private final List<Runnable> postCommitActionList;

    QueueDetachEventList() {
        this.queueDetachRequests = new ArrayList<>();
        this.postCommitActionList = new ArrayList<>();
    }

    public void add(long messageId) {
        queueDetachRequests.add(messageId);
    }

    public void add(long messageId, Runnable postTransactionAction) {
        queueDetachRequests.add(messageId);
        this.postCommitActionList.add(postTransactionAction);
    }

    public List<Long> getMessageIds() {
        return queueDetachRequests;
    }

    List<Runnable> getPostCommitActions() {
        return postCommitActionList;
    }
}
