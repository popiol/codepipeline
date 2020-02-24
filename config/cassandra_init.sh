#!/bin/bash

cassandra -R

sleep 10

cqlsh -f cassandra/create-schema.cql

cqlsh -f cassandra/insert-data.cql

cd cassandra/cassandra-crud-rest/target/universal

unzip cassandra-crud-rest-1.1-SNAPSHOT.zip

cd cassandra-crud-rest-1.1-SNAPSHOT

./bin/cassandra-crud-rest -Dplay.http.secret.key=`cat /app/secret.key`

