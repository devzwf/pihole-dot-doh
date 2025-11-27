<h1 align="center" id="heading"> pihole-dot-doh </h1>

<p align="center">
<a href="https://hub.docker.com/r/devzwf/pihole-dot-doh" target="_blank"><img src="https://img.shields.io/docker/v/devzwf/pihole-dot-doh?logo=docker&label=Docker" alt="Docker Image Version" /></a>
<a href="https://hub.docker.com/r/devzwf/pihole-dot-doh" target="_blank"><img src="https://badgen.net/docker/pulls/devzwf/pihole-dot-doh" /></a>
<a href="https://github.com/devzwf/pihole-dot-doh/blob/main/CHANGELOG.MD"><img src="https://img.shields.io/badge/🔶-Changelog-blue" /></a> 
<a href="https://ko-fi.com/O5O0FG195" target="_blank"><img src="https://img.shields.io/badge/%E2%98%95-Buy%20me%20a%20coffee-red" alt="Buy me a coffee"/></a>
<img src="https://img.shields.io/github/actions/workflow/status/devzwf/pihole-dot-doh/release.yml" alt="GitHub Actions Workflow Status" />
</p>

Official pihole docker with both DoT (DNS over TLS), DoH (DNS over HTTPS)  and unbound clients. Don't browse the web securely and yet still send your DNS queries in plain text!

## Upgrade Notes

> [!CAUTION]
>
> ## !!! THE LATEST VERSION V6 CONTAINS BREAKING CHANGES VERSUS V5
>
> **Pi-hole v6 has been entirely redesigned from the ground up and contains many breaking changes.**
>
> Environment variable names have changed, script locations may have changed.
>
> If you are using volumes to persist your configuration, be careful.<br>Replacing any `v5` image *(`2024.07.0` and earlier)* with a `v6` image will result in updated configuration files. **These changes are irreversible**.
>
> Please read the README carefully before proceeding.
>
> https://docs.pi-hole.net/docker/


## Usage:

For docker parameters, refer to [official pihole docker readme](https://github.com/pi-hole/pi-hole). Below is an docker compose example.

Below is an docker compose example.

```
services:
  pihole:
    container_name: pihole
    image: devzwf/pihole-dot-doh:latest
    ports:
      # DNS Ports
      - "53:53/tcp"
      - "53:53/udp"
      # Default HTTP Port
      - "80:80/tcp"
      # Default HTTPs Port. FTL will generate a self-signed certificate
      - "443:443/tcp"
      # Uncomment the below if using Pi-hole as your DHCP Server
      #- "67:67/udp"
    environment:
      # Set the appropriate timezone for your location (https://en.wikipedia.org/wiki/List_of_tz_database_time_zones), e.g:
      TZ: 'America/Toronto'
      # Set a password to access the web interface. Not setting one will result in a random password being assigned
      FTLCONF_webserver_api_password: '<WEB_PASSWORD>'
      FTLCONF_dns_upstreams: '127.1.1.1#5153;127.0.0.1#5335'
      FTLCONF_dns_listeningMode: 'all'
    # Volumes store your data between container upgrades
    volumes:
      # For persisting Pi-hole's databases and common configuration file
      - './piholev6/etc-pihole:/etc/pihole'
      - './piholev6/config/:/config'
      - './piholev6/log:/var/log
      # Uncomment the below if you have custom dnsmasq config files that you want to persist. Not needed for most.
      #- './piholev6/etc-dnsmasq.d:/etc/dnsmasq.d'
      
    #cap_add:
      # See https://github.com/pi-hole/docker-pi-hole#note-on-capabilities
      # Required if you are using Pi-hole as your DHCP server, else not needed
      #- NET_ADMIN
      #- CAP_SYS_NICE
    restart: unless-stopped
```

### Unbound:

Unbound has been integrated into the image. Unbound can be used as the only upstream dns server for pihole, while unbound itself has been pre-configured to use stubby and cloudflared as its upstream dns servers.

#### Migrate to Unbound:
To use unbound instead of cloudflared and stubby just replace the "Pihole_DNS_" variable with "127.0.0.1#5335".

If you want to change the upstream dns servers for unbound just edit the "forward-records.conf" file in your "/config" mount and comment-out (add a # infront of the "forward-addr") the line and remove the comment for any other dns server like quad9.

#### Configure logging for Unbound
By default logging for unbound has been disabled and routed to "/dev/null". This can be changed to "/var/log/unbound/unbound.log" in the "unbound.conf" file in your "/config" mount. After a restart of the container the log should be viewable with the command "docker exec Pihole-DoT-DoH tail -f /var/log/unbound/unbound.log" from the host.

If no logs are collected you might need to enable "log-queries" in the "unbound.conf" file or need to increase the "verbosity"-level in the "unbound.conf" file. If you made sure unbound is running, you should disable logging again and redirect the logfile to "/dev/null" again!

### Notes:

- Remember to set pihole env PIHOLE_DNS_ to use the DoH / DoT / Unbound IP below. If PIHOLE_DNS_ is NOT set, Pihole will use a non-encrypted service.
  - DoH service (cloudflared) runs at 127.1.1.1#5153. Uses cloudflare (1.1.1.1 / 1.0.0.1) by default
  - DoT service (stubby) runs at 127.2.2.2#5253. Uses google (8.8.8.8 / 8.8.4.4) by default (removed for now)
  - Unbound service run at 127.0.0.1#5335
- In addition to the 2 official paths, you can also map container /config to expose configuration yml files for cloudflared (cloudflared.yml) and stubby (stubby.yml).
  - Edit these files to add / remove services as you wish. The flexibility is yours.
- Credits:
  - Pihole base image is the official [pihole/pihole:latest](https://hub.docker.com/r/pihole/pihole/tags?page=1&name=latest)
  - Cloudflared client was obtained from [official site](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation#linux)
  - Stubby is a standard debian package
  - doh and dot was based from https://github.com/testdasi/pihole-dot-doh
  - Joly0 for the unbound integration (https://github.com/Joly0)
  - update since other container was falling behind version

# Support

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/devzwf)

