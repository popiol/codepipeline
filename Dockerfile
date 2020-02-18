FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://www.apache.org/dist/cassandra/debian 39x main" \
| tee -a /etc/apt/sources.list.d/cassandra.sources.list

RUN apt-get update && apt-get install -y \
curl \
gnupg

curl https://downloads.apache.org/cassandra/KEYS | apt-key add -

RUN apt-get update && apt-get install -y \
cassandra

COPY . /app

WORKDIR /app

CMD ["/bin/sh","config/cassandra_init.sh"]

