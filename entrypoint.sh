#!/bin/sh
set -e  # Exit on error


# Setting variables

# This "migrates" the old DNS1 and DNS2 variables and the newer "PIHOLE_DNS_" variable to the up to date "FTLCONF_dns_upstreams" variable
FTLCONF_dns_upstreams="${FTLCONF_dns_upstreams:-${PIHOLE_DNS_:-${DNS1}${DNS1:+;}${DNS2}}}"

FTLCONF_webserver_api_password="${WEBPASSWORD:-}"
FTLCONF_dns_interface="${INTERFACE:-}"
FTLCONF_LOCAL_IPV4="${ServerIP:-}"
FTLCONF_LOCAL_IPV6="${ServerIPv6:-}"
FTLCONF_dns_listeningMode="${DNSMASQ_LISTENING:-}"


chmod 755 /temp/unbound.sh 
/temp/unbound.sh


# Copy config file if not exists
if [ ! -f /config/cloudflared.yml ]; then
    cp -n /temp/cloudflared.yml /config/
fi

if [ ! -f /config/unbound.conf ]; then
    cp /temp/unbound.conf /config/
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