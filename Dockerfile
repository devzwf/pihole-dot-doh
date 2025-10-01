ARG FRM='pihole/pihole'
ARG TAG='latest'

# Build unbound in an Alpine environment
FROM alpine:latest AS unbound

ARG UNBOUND_VERSION=1.23.0
ARG UNBOUND_SHA256=959bd5f3875316d7b3f67ee237a56de5565f5b35fc9b5fc3cea6cfe735a03bb8
ARG UNBOUND_DOWNLOAD_URL=https://nlnetlabs.nl/downloads/unbound/unbound-1.23.0.tar.gz

WORKDIR /tmp/src

RUN build_deps="curl gcc make libc-dev openssl-dev libevent-dev expat-dev nghttp2-dev protobuf-c-dev" && \
    apk add \
      $build_deps && \
    curl -sSL $UNBOUND_DOWNLOAD_URL -o unbound.tar.gz && \
    echo "${UNBOUND_SHA256} *unbound.tar.gz" | sha256sum -c - && \
    tar xzf unbound.tar.gz && \
    rm -f unbound.tar.gz && \
    cd unbound-${UNBOUND_VERSION} && \
    addgroup unbound && \
    adduser -G unbound -h /etc -s /bin/null -D unbound && \
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
        --enable-subnet \
        --with-ssl=/usr && \
    make -j$(nproc) install && \
    # Copy required Alpine shared libraries
    mkdir -p /usr/local/lib-copy && \
    ldd /usr/local/sbin/unbound | grep "=> /" | awk '{print $3}' | sort | uniq | xargs -I{} cp -L {} /usr/local/lib-copy/ && \
    # Create a tar of the libs for extraction
    cd /usr/local/lib-copy && tar czf /tmp/unbound-libs.tar.gz *

FROM ${FRM}:${TAG}
ARG FRM
ARG TAG
ARG TARGETPLATFORM

RUN mkdir -p /usr/local/etc/unbound

COPY --from=unbound /usr/local/sbin/unbound* /usr/local/sbin/
COPY --from=unbound /usr/local/lib/libunbound* /usr/local/lib/
COPY --from=unbound /usr/local/etc/unbound/* /usr/local/etc/unbound/

RUN apk update && \
    apk add perl openssl ca-certificates libevent

#RUN apk update && \
#  apk add --no-cache bash nano libevent curl wget tzdata shadow perl

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