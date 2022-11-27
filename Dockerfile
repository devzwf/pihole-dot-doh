ARG FRM='pihole/pihole'
ARG TAG='latest'

FROM ${FRM}:${TAG}
ARG FRM
ARG TAG
ARG TARGETPLATFORM

RUN apt update && \
    apt install -y bash nano curl wget stubby

ADD scripts /temp

RUN /bin/bash /temp/install.sh \
    && rm -rf /temp

VOLUME ["/config"]

RUN echo "$(date "+%d.%m.%Y %T") Built from ${FRM} with tag ${TAG}" >> /build_date.info