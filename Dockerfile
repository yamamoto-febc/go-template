FROM golang:1.18 AS builder
MAINTAINER Usacloud Authors <sacloud.users@gmail.com>

RUN  apt-get update && apt-get -y install \
        bash \
        git  \
        make \
        zip  \
        bzr  \
      && apt-get clean \
      && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

ADD . /go/src/github.com/sacloud/go-template
WORKDIR /go/src/github.com/sacloud/go-template
ENV CGO_ENABLED 0
RUN make tools build
# ======

FROM alpine:3.12
MAINTAINER Usacloud Authors <sacloud.users@gmail.com>

RUN apk add --no-cache --update ca-certificates
COPY --from=builder /go/src/github.com/sacloud/usacloud/bin/usacloud /usr/bin/

ENTRYPOINT ["/usr/bin/usacloud"]