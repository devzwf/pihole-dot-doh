#!/bin/bash

# Let Download and install Cloudflare depending on the architecture
set -eux; 
ARCH="$(apk --print-arch | awk -F'-' '{print $NF}')"


# install dnscrypt-proxy
apk add --update --no-cache dnscrypt-proxy \
    && echo "$(date "+%d.%m.%Y %T") DNSCrypt-proxy $(dnscrypt-proxy -version) installed for ${ARCH}" >> /build_date.info

# install stubby
apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ stubby \
    && echo "$(date "+%d.%m.%Y %T") $(stubby -V) installed for ${ARCH}" >> /build_date.info

# install unbound 
apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ unbound \
    && echo "$(date "+%d.%m.%Y %T") Unbound $(unbound -V | head -1) installed for ${ARCH}" >> /build_date.info
 
# add pihole version to build.info
echo "$(date "+%d.%m.%Y %T")  $(/usr/local/bin/pihole -v)"
echo "$(date "+%d.%m.%Y %T")  $(/usr/local/bin/pihole -v |sed -n '1p') installed" >> /build_date.info
echo "$(date "+%d.%m.%Y %T")  $(/usr/local/bin/pihole -v |sed -n '2p') installed" >> /build_date.info
echo "$(date "+%d.%m.%Y %T")  $(/usr/local/bin/pihole -v |sed -n '3p') installed" >> /build_date.info
# clean up
rm -rf /tmp/* /var/tmp/*