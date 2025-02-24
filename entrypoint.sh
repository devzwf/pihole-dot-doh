#!/bin/sh
set -e  # Exit on error

chmod 755 /temp/unbound.sh 
/temp/unbound.sh


# # Creating pihole-dot-doh service
# mkdir -p /etc/services.d/pihole-dot-doh
# mkdir -p /config/
# Copy config file if not exists
if [ ! -f /config/cloudflared.yml ]; then
    cp -n /temp/cloudflared.yml /config/
fi

if [ ! -f /config/unbound.conf ]; then
    /temp/unbound.conf /config/
fi
if [ ! -f /config/forward-records.conf ]; then
    cp -n /temp/forward-records.conf /config/
fi


# Start Unbound in the foreground
echo "Starting Unbound..."
/usr/local/sbin/unbound -d -p -c /config/unbound.conf &

echo "Starting Cloudflared..."
/usr/local/bin/cloudflared --config /config/cloudflared.yml &

echo "Starting Pihole..."
# Start pihole
/usr/bin/start.sh