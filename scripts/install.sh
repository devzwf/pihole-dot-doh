#!/bin/bash

# clean stubby config
mkdir -p /etc/stubby \
    && rm -f /etc/stubby/stubby.yml

# Let Download and install Cloudflare depending on the architecture
set -eux; 
ARCH="$(dpkg --print-architecture | awk -F'-' '{print $NF}')"
case "$ARCH" in
    aarch64|arm64)
        CF_PACKAGE="cloudflared-linux-arm64.deb"
        ;;
    arm)
        CF_PACKAGE="cloudflared-linux-arm.deb"
        ;;
    armhf)
        CF_PACKAGE="cloudflared-linux-armhf.deb"
        ;;
    amd64|x86_64)
        CF_PACKAGE="cloudflared-linux-amd64.deb"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1;
        ;;
esac;

# install cloudflared
cd /tmp \
&& wget https://github.com/cloudflare/cloudflared/releases/latest/download/${CF_PACKAGE} \
&& apt install -y ./${CF_PACKAGE} \
&& rm -f ./${CF_PACKAGE} \
&& echo "$(date "+%d.%m.%Y %T") $(cloudflared -V) installed for ${ARCH}" >> /build_date.info


useradd -s /usr/sbin/nologin -r -M cloudflared \
    && chown cloudflared:cloudflared /usr/local/bin/cloudflared
    
# clean cloudflared config
mkdir -p /etc/cloudflared \
    && rm -f /etc/cloudflared/config.yml

# clean up
apt -y autoremove \
    && apt -y autoclean \
    && apt -y clean \
    && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Creating pihole-dot-doh service
mkdir -p /etc/services.d/pihole-dot-doh

# run file
echo '#!/usr/bin/env bash' | tee /etc/services.d/pihole-dot-doh/run
# Copy config file if not exists
echo 'cp -n /temp/stubby.yml /config/' | tee -a /etc/services.d/pihole-dot-doh/run
echo 'cp -n /temp/cloudflared.yml /config/' | tee -a /etc/services.d/pihole-dot-doh/run
# run stubby in background
echo 's6-echo "Starting stubby"' | tee -a /etc/services.d/pihole-dot-doh/run
echo 'stubby -g -C /config/stubby.yml' | tee -a /etc/services.d/pihole-dot-doh/run
# run cloudflared in foreground
echo 's6-echo "Starting cloudflared"' | tee -a /etc/services.d/pihole-dot-doh/run
echo '/usr/local/bin/cloudflared --config /config/cloudflared.yml' | tee -a /etc/services.d/pihole-dot-doh/run
chmod 755 /etc/services.d/pihole-dot-doh/run

# finish file
echo '#!/usr/bin/env bash' | tee /etc/services.d/pihole-dot-doh/finish
echo 's6-echo "Stopping stubby"' | tee -a /etc/services.d/pihole-dot-doh/finish
echo 'killall -9 stubby' | tee -a /etc/services.d/pihole-dot-doh/finish
echo 's6-echo "Stopping cloudflared"' | tee -a /etc/services.d/pihole-dot-doh/finish
echo 'killall -9 cloudflared' | tee -a /etc/services.d/pihole-dot-doh/finish
chmod 755 /etc/services.d/pihole-dot-doh/finish
