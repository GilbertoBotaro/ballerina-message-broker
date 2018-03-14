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
 */

package io.ballerina.messaging.broker.core;

import io.ballerina.messaging.broker.auth.authorization.AuthorizationHandler;
import io.ballerina.messaging.broker.auth.authorization.enums.ResourceAction;
import io.ballerina.messaging.broker.auth.authorization.enums.ResourceAuthScope;
import io.ballerina.messaging.broker.auth.authorization.enums.ResourceType;
import io.ballerina.messaging.broker.auth.exception.BrokerAuthException;
import io.ballerina.messaging.broker.auth.exception.BrokerAuthNotFoundException;
import io.ballerina.messaging.broker.common.ResourceNotFoundException;
import io.ballerina.messaging.broker.common.ValidationException;
import io.ballerina.messaging.broker.common.data.types.FieldTable;
import io.ballerina.messaging.broker.core.transaction.DistributedTransaction;
import io.ballerina.messaging.broker.core.transaction.LocalTransaction;

import java.util.Collection;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import javax.security.auth.Subject;
import javax.transaction.xa.Xid;

/**
 * Broker APIs protected by authorization.
 */
public class SecureBrokerImpl implements Broker {

    /**
     * Wrapper object of the {@link BrokerImpl}
     */
    private final Broker broker;
    /**
     * Username entity
     */
    private final Subject subject;
    /**
     * The @{@link AuthorizationHandler} to handle authorization.
     */
    private final AuthorizationHandler authHandler;

    public SecureBrokerImpl(Broker broker, Subject subject, AuthorizationHandler authHandler) {
        this.broker = broker;
        this.subject = subject;
        this.authHandler = authHandler;
    }

    @Override
    public void publish(Message message) throws BrokerException {
        broker.publish(message);
    }

    @Override
    public void acknowledge(String queueName, Message message) throws BrokerException {
        broker.acknowledge(queueName, message);
    }

    @Override
    public Set<QueueHandler> enqueue(Xid xid, Message message) throws BrokerException {
        return broker.enqueue(xid, message);
    }

    @Override
    public QueueHandler dequeue(Xid xid, String queueName, Message message) throws BrokerException {
        return broker.dequeue(xid, queueName, message);
    }

    @Override
    public void addConsumer(Consumer consumer) throws BrokerException {
        broker.addConsumer(consumer);
    }

    @Override
    public void removeConsumer(Consumer consumer) {
        broker.removeConsumer(consumer);
    }

    @Override
    public void declareExchange(String exchangeName, String type, boolean passive, boolean durable)
            throws BrokerException, ValidationException, BrokerAuthException {
        authHandler.handle(ResourceAuthScope.EXCHANGES_CREATE, subject);
        broker.declareExchange(exchangeName, type, passive, durable);
        if (!passive) {
            authHandler.createAuthResource(ResourceType.EXCHANGE, exchangeName, durable, subject);
        }
    }

    @Override
    public void createExchange(String exchangeName, String type, boolean durable)
            throws BrokerException, ValidationException, BrokerAuthException {
        authHandler.handle(ResourceAuthScope.EXCHANGES_CREATE, subject);
        broker.createExchange(exchangeName, type, durable);
        authHandler.createAuthResource(ResourceType.EXCHANGE, exchangeName, durable, subject);
    }

    @Override
    public boolean deleteExchange(String exchangeName, boolean ifUnused)
            throws BrokerException, ValidationException, BrokerAuthException, ResourceNotFoundException {
        authHandler.handle(ResourceAuthScope.EXCHANGES_DELETE, subject);
        boolean success = broker.deleteExchange(exchangeName, ifUnused);
        if (success) {
            authHandler.deleteAuthResource(ResourceType.EXCHANGE, exchangeName);
        }
        return success;
    }

    @Override
    public boolean createQueue(String queueName, boolean passive, boolean durable, boolean autoDelete)
            throws BrokerException, ValidationException, BrokerAuthException {
        authHandler.handle(ResourceAuthScope.QUEUES_CREATE, subject);
        boolean succeed = broker.createQueue(queueName, passive, durable, autoDelete);
        if (succeed) {
            authHandler.createAuthResource(ResourceType.QUEUE, queueName, durable, subject);
        }
        return succeed;
    }

    @Override
    public int deleteQueue(String queueName, boolean ifUnused, boolean ifEmpty) throws BrokerException,
            ValidationException, ResourceNotFoundException, BrokerAuthException, BrokerAuthNotFoundException {

        if (!queueExists(queueName)) {
            throw new ResourceNotFoundException("Queue [ " + queueName + " ] Not found");
        }

        authHandler.handle(ResourceType.QUEUE, queueName, ResourceAction.DELETE, subject);
        int messageCount = broker.deleteQueue(queueName, ifUnused, ifEmpty);
        authHandler.deleteAuthResource(ResourceType.QUEUE, queueName);
        return messageCount;
    }

    @Override
    public boolean queueExists(String queueName) {
        return broker.queueExists(queueName);
    }

    @Override
    public void bind(String queueName, String exchangeName, String routingKey, FieldTable arguments)
            throws BrokerException, ValidationException {
        broker.bind(queueName, exchangeName, routingKey, arguments);
    }

    @Override
    public void unbind(String queueName, String exchangeName, String routingKey) throws BrokerException,
            ValidationException {
        broker.unbind(queueName, exchangeName, routingKey);
    }

    @Override
    public void startMessageDelivery() {
        broker.startMessageDelivery();
    }

    @Override
    public int purgeQueue(String queueName) throws ResourceNotFoundException, ValidationException {
        return broker.purgeQueue(queueName);
    }

    @Override
    public void stopMessageDelivery() {
        broker.stopMessageDelivery();
    }

    @Override
    public void shutdown() {
        broker.shutdown();
    }

    @Override
    public void requeue(String queueName, Message message) throws BrokerException, ResourceNotFoundException {
        broker.requeue(queueName, message);
    }

    @Override
    public Collection<QueueHandler> getAllQueues() throws BrokerAuthException {
        authHandler.handle(ResourceAuthScope.QUEUES_GET, subject);
        return broker.getAllQueues();
    }

    @Override
    public QueueHandler getQueue(String queueName)
            throws BrokerAuthNotFoundException, BrokerAuthException, ResourceNotFoundException {
        QueueHandler queue = broker.getQueue(queueName);

        if (Objects.isNull(queue)) {
            throw new ResourceNotFoundException("Queue [ " + queueName + " ] Not found");
        }
        authHandler.handle(ResourceType.QUEUE, queueName, ResourceAction.GET, subject);
        return broker.getQueue(queueName);
    }

    @Override
    public void moveToDlc(String queueName, Message message) throws BrokerException {
        broker.moveToDlc(queueName, message);
    }

    @Override
    public Collection<Exchange> getAllExchanges() throws BrokerAuthException {
        authHandler.handle(ResourceAuthScope.SCOPES_GET, subject);
        return broker.getAllExchanges();
    }

    @Override
    public Map<String, BindingSet> getAllBindingsForExchange(String exchangeName) throws ValidationException {
        return broker.getAllBindingsForExchange(exchangeName);
    }

    @Override
    public Exchange getExchange(String exchangeName) throws BrokerAuthNotFoundException, BrokerAuthException {
        authHandler.handle(ResourceType.EXCHANGE, exchangeName, ResourceAction.GET, subject);
        return broker.getExchange(exchangeName);
    }

    @Override
    public LocalTransaction newLocalTransaction() {
        return broker.newLocalTransaction();
    }

    @Override
    public DistributedTransaction newDistributedTransaction() {
        return broker.newDistributedTransaction();
    }
}