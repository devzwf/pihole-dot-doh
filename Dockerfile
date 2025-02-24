ARG FRM='pihole/pihole'
ARG TAG='latest'

FROM alpine as unbound

ARG UNBOUND_VERSION=1.22.0
ARG UNBOUND_SHA256=c5dd1bdef5d5685b2cedb749158dd152c52d44f65529a34ac15cd88d4b1b3d43
ARG UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-1.22.0.tar.gz

WORKDIR /tmp/src

RUN build_deps="curl gcc libc-dev libevent-dev  make shadow openssl-dev openssl nghttp2-dev nghttp2" && \
  set -x && \
  apk update && apk add --no-cache \
  $build_deps \
  ca-certificates \
  expat \
  expat-dev \
  protobuf-c \
  protobuf-c-dev && \
  curl -sSL $UNBOUND_DOWNLOAD_URL -o unbound.tar.gz && \
  echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
  tar xzf unbound.tar.gz && \
  rm -f unbound.tar.gz && \
  cd unbound-${UNBOUND_VERSION} && \
  groupadd unbound && \
  useradd -g unbound -s /dev/null -d /etc unbound && \
  ./configure \
  --disable-dependency-tracking \
  --with-pthreads \
  --with-username=unbound \
  --with-libevent \
  --with-libnghttp2 \
  --enable-dnstap \
  --enable-tfo-server \
  --enable-tfo-client \
  --enable-event-api \
  --enable-subnet && \
  make -j$(nproc) install && \
  rm -rf \
  /tmp/* \
  /var/tmp/* 

FROM ${FRM}:${TAG}
ARG FRM
ARG TAG
ARG TARGETPLATFORM

RUN mkdir -p /usr/local/etc/unbound

COPY --from=unbound /usr/local/sbin/unbound* /usr/local/sbin/
COPY --from=unbound /usr/local/lib/libunbound* /usr/local/lib/
COPY --from=unbound /usr/local/etc/unbound/* /usr/local/etc/unbound/

RUN apk update && \
  apk add --no-cache bash nano libevent curl wget tzdata shadow perl

ADD scripts /temp

RUN groupadd unbound \
  && useradd -g unbound unbound 
RUN /bin/bash /temp/install.sh \
  && rm -rf /temp/install.sh 

VOLUME ["/config"]

RUN echo "$(date "+%d.%m.%Y %T") Built from ${FRM} with tag ${TAG}" >> /build_date.info

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]