#!/bin/bash
set -eux; 

# Get architecture
ARCH="$(apk --print-arch | awk -F'-' '{print $NF}')"

# 1. Install dnscrypt-proxy from edge community
apk add --update --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
    dnscrypt-proxy \
    && echo "$(date "+%d.%m.%Y %T") DNSCrypt-proxy $(dnscrypt-proxy -version) installed for ${ARCH}" >> /build_date.info

# 2. Install stubby from edge community
apk add --update --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ \
    stubby \
    && echo "$(date "+%d.%m.%Y %T") $(stubby -V) installed for ${ARCH}" >> /build_date.info

# 3. Install unbound from edge main
apk add --update --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ \
    unbound \
    && echo "$(date "+%d.%m.%Y %T") Unbound $(unbound -V | head -1) installed for ${ARCH}" >> /build_date.info

# 4. Pi-hole version logging
echo "$(date "+%d.%m.%Y %T")  $(/usr/local/bin/pihole -v)"
/usr/local/bin/pihole -v | sed -n '1,3p' | while read -r line; do
    echo "$(date "+%d.%m.%Y %T") $line installed" >> /build_date.info
done

# Clean up
rm -rf /tmp/* /var/tmp/*