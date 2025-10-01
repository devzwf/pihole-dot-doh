#!/bin/bash

# Let Download and install Cloudflare depending on the architecture
set -eux; 
ARCH="$(apk --print-arch | awk -F'-' '{print $NF}')"
case "$ARCH" in
    aarch64|arm64)
        CF_PACKAGE="cloudflared-linux-arm64"
        ;;
    arm|armv7)
        CF_PACKAGE="cloudflared-linux-arm"
        ;;
    armhf)
        CF_PACKAGE="cloudflared-linux-armhf"
        ;;
    amd64|x86_64)
        CF_PACKAGE="cloudflared-linux-amd64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1;
        ;;
esac;

# install cloudflared
wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/${CF_PACKAGE} \
    -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared \
&& echo "$(date "+%d.%m.%Y %T") $(cloudflared -V) installed for ${ARCH}" >> /build_date.info


useradd -s /usr/sbin/nologin -r -M cloudflared \
    && chown cloudflared:cloudflared /usr/local/bin/
    
# install stubby
apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ stubby \
    && echo "$(date "+%d.%m.%Y %T") $(stubby -V) installed for ${ARCH}" >> /build_date.info

# install unbound 
apk add --update --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/main/ unbound \
    && echo "$(date "+%d.%m.%Y %T") Unbound $(unbound -V | head -1) installed for ${ARCH}" >> /build_date.info

# clean cloudflared config
mkdir -p /etc/cloudflared \
    && rm -f /etc/cloudflared/config.yml
    
# add unbound version to build.info
#echo "$(date "+%d.%m.%Y %T") Unbound $(/usr/local/sbin/unbound -V | head -1) installed for ${ARCH}" >> /build_date.info    

# add pihole version to build.info
echo "$(date "+%d.%m.%Y %T")  $(/usr/local/bin/pihole -v)"
echo "$(date "+%d.%m.%Y %T")  $(/usr/local/bin/pihole -v |sed -n '1p') installed" >> /build_date.info
echo "$(date "+%d.%m.%Y %T")  $(/usr/local/bin/pihole -v |sed -n '2p') installed" >> /build_date.info
echo "$(date "+%d.%m.%Y %T")  $(/usr/local/bin/pihole -v |sed -n '3p') installed" >> /build_date.info
# clean up
rm -rf /tmp/* /var/tmp/*