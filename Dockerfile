ARG FRM='pihole/pihole'
ARG TAG='latest'

ARG UNBOUND_VERSION=1.24.2
ARG CLOUDFLARED_VERSION=2025.11.1

FROM ${FRM}:${TAG}
ARG FRM
ARG TAG
ARG TARGETPLATFORM

RUN apk update && \
    apk add perl openssl ca-certificates libevent

ADD scripts /temp

RUN /bin/bash /temp/install.sh \
  && rm -rf /temp/install.sh 

VOLUME ["/config"]

RUN echo "$(date "+%d.%m.%Y %T") Built from ${FRM} with tag ${TAG}" >> /build_date.info

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
