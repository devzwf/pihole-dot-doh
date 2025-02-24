#!/bin/bash

# Let Download and install Cloudflare depending on the architecture
set -eux; 
ARCH="$(apk --print-arch | awk -F'-' '{print $NF}')"
case "$ARCH" in
    aarch64|arm64)
        CF_PACKAGE="cloudflared-linux-arm64"
        ;;
    arm)
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
    && chown cloudflared:cloudflared /usr/local/bin/cloudflared
    
# clean cloudflared config
mkdir -p /etc/cloudflared \
    && rm -f /etc/cloudflared/config.yml
    
# add unbound version to build.info
echo "$(date "+%d.%m.%Y %T") Unbound $(/usr/local/sbin/unbound -V | head -1) installed for ${ARCH}" >> /build_date.info    

# clean up
rm -rf /tmp/* /var/tmp/*





# # run file
# echo '#!/usr/bin/env bash' | tee /etc/services.d/pihole-dot-doh/run
# # Copy config file if not exists
# echo 'cp -n /temp/stubby.yml /config/' | tee -a /etc/services.d/pihole-dot-doh/run
# echo 'cp -n /temp/cloudflared.yml /config/' | tee -a /etc/services.d/pihole-dot-doh/run
# echo 'cp -n /temp/unbound.conf /config/' | tee -a /etc/services.d/pihole-dot-doh/run
# echo 'cp -n /temp/forward-records.conf /config/' | tee -a /etc/services.d/pihole-dot-doh/run
# # run unbound in background
# echo 's6-echo "Starting unbound"' | tee -a /etc/services.d/pihole-dot-doh/run
# echo '/usr/local/sbin/unbound -p -c /config/unbound.conf' | tee -a /etc/services.d/pihole-dot-doh/run
# # run stubby in background
# # echo 's6-echo "Starting stubby"' | tee -a /etc/services.d/pihole-dot-doh/run
# # echo 'stubby -g -C /config/stubby.yml' | tee -a /etc/services.d/pihole-dot-doh/run
# # run cloudflared in foreground
# echo 's6-echo "Starting cloudflared"' | tee -a /etc/services.d/pihole-dot-doh/run
# echo '/usr/local/bin/cloudflared --config /config/cloudflared.yml' | tee -a /etc/services.d/pihole-dot-doh/run
# chmod 755 /etc/services.d/pihole-dot-doh/run

# # finish file
# echo '#!/usr/bin/env bash' | tee /etc/services.d/pihole-dot-doh/finish
# echo 's6-echo "Stopping stubby"' | tee -a /etc/services.d/pihole-dot-doh/finish
# echo 'killall -9 stubby' | tee -a /etc/services.d/pihole-dot-doh/finish
# echo 's6-echo "Stopping cloudflared"' | tee -a /etc/services.d/pihole-dot-doh/finish
# echo 'killall -9 cloudflared' | tee -a /etc/services.d/pihole-dot-doh/finish
# echo 's6-echo "Stopping unbound"' | tee -a /etc/services.d/pihole-dot-doh/finish
# echo 'killall -9 unbound' | tee -a /etc/services.d/pihole-dot-doh/finish
# chmod 755 /etc/services.d/pihole-dot-doh/finish


# # creating oneshot for unbound
# mkdir -p /etc/cont-init.d/
# # run file
# cp -n /temp/unbound.sh /etc/cont-init.d/unbound
# chmod 755 /etc/cont-init.d/unbound
