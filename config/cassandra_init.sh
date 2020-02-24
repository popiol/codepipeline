#!/bin/bash

cassandra -R

sleep 10

cqlsh -f cassandra/create-schema.cql

cqlsh -f cassandra/insert-data.cql

cd cassandra/cassandra-crud-rest/target/universal

unzip cassandra-crud-rest-1.1-SNAPSHOT.zip

cd cassandra-crud-rest-1.1-SNAPSHOT

./bin/cassandra-crud-rest -Dplay.http.secret.key=ad31779d4ee49d5ad5162bf1429c32e2e9933f3b

