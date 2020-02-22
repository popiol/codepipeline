FROM ubuntu

RUN export DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
curl gnupg tzdata

RUN echo "deb https://downloads.apache.org/cassandra/debian 39x main" \
| tee -a /etc/apt/sources.list.d/cassandra.sources.list

RUN curl -sL https://downloads.apache.org/cassandra/KEYS | apt-key add

RUN apt update && apt install -y \
cassandra

RUN echo "deb https://dl.bintray.com/sbt/debian /" \
| tee -a /etc/apt/sources.list.d/sbt.list

RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add

RUN apt update && apt install -y \
sbt

COPY . /app

WORKDIR /app

EXPOSE 9000

CMD ["/bin/sh","config/cassandra_init.sh"]

