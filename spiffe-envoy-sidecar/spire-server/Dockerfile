FROM centos:7

ARG SPIRE_VERSION=0.6.2
ARG SPIRE_RELEASE=https://github.com/spiffe/spire/releases/download/${SPIRE_VERSION}/spire-${SPIRE_VERSION}-linux-x86_64-glibc.tar.gz
ARG SPIRE_DIR=/opt/spire

RUN curl --silent --location $SPIRE_RELEASE | tar -xzf -
RUN mv spire-${SPIRE_VERSION} ${SPIRE_DIR}

WORKDIR ${SPIRE_DIR}
COPY conf/agent.conf conf/agent/agent.conf
COPY conf/server.conf conf/server/server.conf

EXPOSE 8080
EXPOSE 8081
ENTRYPOINT /opt/spire/spire-server run