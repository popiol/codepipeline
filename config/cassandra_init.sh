#!/bin/bash

cassandra -R

sleep 10

cqlsh -f cassandra/create-schema.cql

cqlsh -f cassandra/insert-data.cql

cd cassandra/cassandra-crud-rest

sbt run

