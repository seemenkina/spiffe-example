FROM golang:1.9-alpine

LABEL Description="Simple Verification SPIFFE: Blog"
LABEL vendor="SPIFFE"
LABEL version="0.1.0"

RUN apk update && apk upgrade && \
    apk add --no-cache bash git

RUN apk add --update make gcc build-base
RUN apk add --update libtool
RUN apk add --update openssl
    
RUN rm -rf /var/cache/apk/*

WORKDIR /spiffe/example/verification/blog

COPY  nc.sh ghostunnel_client.sh /
COPY ./keys/ /keys/

RUN git clone https://github.com/spiffe/ghostunnel.git /go/src/github.com/square/ghostunnel
RUN go build -o /usr/bin/ghostunnel github.com/square/ghostunnel
