/*
 * Copyright (c) 2018, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
 *
 * WSO2 Inc. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

-- WSO2 Message Broker MySQL Database schema --

-- Start of Message Store Tables --

CREATE TABLE IF NOT EXISTS MB_EXCHANGE (
                        EXCHANGE_NAME VARCHAR(256) NOT NULL,
                        EXCHANGE_TYPE VARCHAR(256) NOT NULL,
                        PRIMARY KEY(EXCHANGE_NAME)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_QUEUE_METADATA (
                        QUEUE_NAME VARCHAR(256) NOT NULL,
                        QUEUE_ARGUMENTS VARBINARY(10000) NOT NULL,
                        PRIMARY KEY(QUEUE_NAME)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_BINDING (
                        EXCHANGE_NAME VARCHAR(256) NOT NULL,
                        QUEUE_NAME VARCHAR(256) NOT NULL,
                        ROUTING_KEY VARCHAR(256) NOT NULL,
                        ARGUMENTS VARBINARY(2048) NOT NULL,
                        PRIMARY KEY (EXCHANGE_NAME, QUEUE_NAME, ROUTING_KEY, ARGUMENTS),
                        FOREIGN KEY (EXCHANGE_NAME) REFERENCES MB_EXCHANGE (EXCHANGE_NAME) ON DELETE CASCADE,
                        FOREIGN KEY (QUEUE_NAME) REFERENCES MB_QUEUE_METADATA (QUEUE_NAME) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_METADATA (
                MESSAGE_ID BIGINT NOT NULL,
                EXCHANGE_NAME VARCHAR(256) NOT NULL,
                ROUTING_KEY VARCHAR(256) NOT NULL,
                CONTENT_LENGTH BIGINT NOT NULL,
                MESSAGE_METADATA VARBINARY(60000) NOT NULL,
                PRIMARY KEY (MESSAGE_ID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_CONTENT (
                MESSAGE_ID BIGINT NOT NULL,
                CONTENT_OFFSET INTEGER,
                MESSAGE_CONTENT VARBINARY(65500) NOT NULL,
                PRIMARY KEY (MESSAGE_ID, CONTENT_OFFSET),
                FOREIGN KEY (MESSAGE_ID) REFERENCES MB_METADATA (MESSAGE_ID)
                ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_QUEUE_MAPPING (
                MESSAGE_ID BIGINT NOT NULL,
                QUEUE_NAME VARCHAR(256) NOT NULL,
                PRIMARY KEY (MESSAGE_ID, QUEUE_NAME),
                FOREIGN KEY (MESSAGE_ID) REFERENCES MB_METADATA (MESSAGE_ID)
                ON DELETE CASCADE,
                FOREIGN KEY (QUEUE_NAME) REFERENCES MB_QUEUE_METADATA (QUEUE_NAME)
                ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Distributed Transaction Tables --
CREATE TABLE IF NOT EXISTS MB_DTX_XID (
                INTERNAL_XID BIGINT UNIQUE NOT NULL,
                FORMAT_CODE INTEGER NOT NULL,
                GLOBAL_ID VARBINARY(260), -- AMQP-10 vbin8 type
                BRANCH_ID VARBINARY(260), -- AMQP-10 vbin8 type
                PRIMARY KEY (INTERNAL_XID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_DTX_ENQUEUE_METADATA (
                INTERNAL_XID BIGINT NOT NULL,
                MESSAGE_ID BIGINT NOT NULL,
                EXCHANGE_NAME VARCHAR(256) NOT NULL,
                ROUTING_KEY VARCHAR(256) NOT NULL,
                CONTENT_LENGTH BIGINT NOT NULL,
                MESSAGE_METADATA VARBINARY(60000) NOT NULL,
                PRIMARY KEY (MESSAGE_ID),
                FOREIGN KEY (INTERNAL_XID) REFERENCES MB_DTX_XID (INTERNAL_XID)
                ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_DTX_ENQUEUE_CONTENT (
                INTERNAL_XID BIGINT NOT NULL,
                MESSAGE_ID BIGINT NOT NULL,
                CONTENT_OFFSET BIGINT NOT NULL,
                MESSAGE_CONTENT VARBINARY(65500) NOT NULL,
                PRIMARY KEY (INTERNAL_XID, MESSAGE_ID, CONTENT_OFFSET),
                FOREIGN KEY (MESSAGE_ID) REFERENCES MB_DTX_ENQUEUE_METADATA (MESSAGE_ID)
                ON DELETE CASCADE,
                FOREIGN KEY (INTERNAL_XID) REFERENCES MB_DTX_XID (INTERNAL_XID)
                ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_DTX_ENQUEUE_MAPPING (
                INTERNAL_XID BIGINT NOT NULL,
                MESSAGE_ID BIGINT NOT NULL,
                QUEUE_NAME VARCHAR(256) NOT NULL,
                PRIMARY KEY (INTERNAL_XID, MESSAGE_ID, QUEUE_NAME),
                FOREIGN KEY (MESSAGE_ID) REFERENCES MB_DTX_ENQUEUE_METADATA (MESSAGE_ID)
                ON DELETE CASCADE,
                FOREIGN KEY (QUEUE_NAME) REFERENCES MB_QUEUE_METADATA (QUEUE_NAME)
                ON DELETE CASCADE,
                FOREIGN KEY (INTERNAL_XID) REFERENCES MB_DTX_XID (INTERNAL_XID)
                ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_DTX_DEQUEUE_MAPPING (
                INTERNAL_XID BIGINT NOT NULL,
                MESSAGE_ID BIGINT NOT NULL,
                QUEUE_NAME VARCHAR(256) NOT NULL,
                PRIMARY KEY (INTERNAL_XID, MESSAGE_ID, QUEUE_NAME),
                FOREIGN KEY (MESSAGE_ID) REFERENCES MB_METADATA (MESSAGE_ID)
                ON DELETE CASCADE,
                FOREIGN KEY (QUEUE_NAME) REFERENCES MB_QUEUE_METADATA (QUEUE_NAME)
                ON DELETE CASCADE,
                FOREIGN KEY (INTERNAL_XID) REFERENCES MB_DTX_XID (INTERNAL_XID)
                ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO MB_EXCHANGE (EXCHANGE_NAME, EXCHANGE_TYPE)  VALUES('<<default>>', 'direct');
INSERT INTO MB_EXCHANGE (EXCHANGE_NAME, EXCHANGE_TYPE)  VALUES('amq.dlx', 'direct');
INSERT INTO MB_EXCHANGE (EXCHANGE_NAME, EXCHANGE_TYPE)  VALUES('amq.direct', 'direct');
INSERT INTO MB_EXCHANGE (EXCHANGE_NAME, EXCHANGE_TYPE)  VALUES('amq.topic', 'topic');

-- End of Message Store Tables --

-- Start of RDBMS based Coordinator Election Tables  --

CREATE TABLE IF NOT EXISTS MB_COORDINATOR_HEARTBEAT (
                        ANCHOR INT NOT NULL,
                        NODE_ID VARCHAR(512) NOT NULL,
                        LAST_HEARTBEAT BIGINT NOT NULL,
                        PRIMARY KEY (ANCHOR)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

CREATE TABLE IF NOT EXISTS MB_NODE_HEARTBEAT (
                        NODE_ID VARCHAR(512) NOT NULL,
                        LAST_HEARTBEAT BIGINT NOT NULL,
                        IS_NEW_NODE TINYINT NOT NULL,
                        PRIMARY KEY (NODE_ID)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- End of RDBMS based Coordinator Election Tables  --


-- Start of Broker Authorization Tables --

CREATE TABLE IF NOT EXISTS MB_AUTH_SCOPE (
                SCOPE_ID INTEGER NOT NULL AUTO_INCREMENT,
                SCOPE_NAME VARCHAR(512) NOT NULL,
                CONSTRAINT SCOPE_NAME_CONSTRAINT UNIQUE (SCOPE_NAME),
                PRIMARY KEY (SCOPE_ID)
);

CREATE TABLE IF NOT EXISTS MB_AUTH_SCOPE_MAPPING (
                SCOPE_ID INTEGER NOT NULL,
                USER_GROUP_ID VARCHAR(256) NOT NULL,
                PRIMARY KEY (SCOPE_ID, USER_GROUP_ID),
                FOREIGN KEY (SCOPE_ID) REFERENCES MB_AUTH_SCOPE (SCOPE_ID)
                ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS MB_AUTH_RESOURCE (
                RESOURCE_ID INTEGER NOT NULL AUTO_INCREMENT,
                RESOURCE_TYPE VARCHAR(256) NOT NULL,
                RESOURCE_NAME VARCHAR(256) NOT NULL,
                OWNER_ID VARCHAR(256) NOT NULL,
                PRIMARY KEY (RESOURCE_ID),
                CONSTRAINT RESOURCE_CONSTRAINT UNIQUE (RESOURCE_TYPE, RESOURCE_NAME)
);

CREATE TABLE IF NOT EXISTS MB_AUTH_RESOURCE_MAPPING (
                RESOURCE_ID INTEGER NOT NULL,
                RESOURCE_ACTION VARCHAR(256) NOT NULL,
                USER_GROUP_ID VARCHAR(256) NOT NULL,
                PRIMARY KEY (RESOURCE_ID, RESOURCE_ACTION, USER_GROUP_ID),
                FOREIGN KEY (RESOURCE_ID) REFERENCES MB_AUTH_RESOURCE (RESOURCE_ID)
                ON DELETE CASCADE
);

CREATE INDEX IDX_RESOURCE_KEY ON MB_AUTH_RESOURCE (RESOURCE_TYPE, RESOURCE_NAME);

INSERT INTO MB_AUTH_SCOPE (SCOPE_NAME) VALUES ('exchanges:create');
INSERT INTO MB_AUTH_SCOPE (SCOPE_NAME) VALUES ('exchanges:delete');
INSERT INTO MB_AUTH_SCOPE (SCOPE_NAME) VALUES ('exchanges:get');
INSERT INTO MB_AUTH_SCOPE (SCOPE_NAME) VALUES ('queues:create');
INSERT INTO MB_AUTH_SCOPE (SCOPE_NAME) VALUES ('queues:delete');
INSERT INTO MB_AUTH_SCOPE (SCOPE_NAME) VALUES ('queues:get');
INSERT INTO MB_AUTH_SCOPE (SCOPE_NAME) VALUES ('resources:grant');
INSERT INTO MB_AUTH_SCOPE (SCOPE_NAME) VALUES ('scopes:update');
INSERT INTO MB_AUTH_SCOPE (SCOPE_NAME) VALUES ('scopes:get');

INSERT INTO MB_AUTH_SCOPE_MAPPING (SCOPE_ID, USER_GROUP_ID) SELECT SCOPE_ID, 'admin' FROM MB_AUTH_SCOPE;

INSERT INTO MB_AUTH_RESOURCE (RESOURCE_TYPE, RESOURCE_NAME ,OWNER_ID) VALUES('exchange', '<<default>>','admin');
INSERT INTO MB_AUTH_RESOURCE (RESOURCE_TYPE, RESOURCE_NAME ,OWNER_ID) VALUES('exchange', 'amq.direct','admin');
INSERT INTO MB_AUTH_RESOURCE (RESOURCE_TYPE, RESOURCE_NAME ,OWNER_ID) VALUES('exchange', 'amq.topic','admin');
INSERT INTO MB_AUTH_RESOURCE (RESOURCE_TYPE, RESOURCE_NAME ,OWNER_ID) VALUES('queue', 'amq.dlq','admin');
-- End of Broker Authorization Tables --

