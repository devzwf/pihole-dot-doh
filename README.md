<h1 align="center" id="heading"> pihole-dot-doh </h1>

<a href="https://github.com/devzwf/pihole-dot-doh/blob/main/CHANGELOG.MD"><img src="https://img.shields.io/badge/🔶-Changelog-blue" /></a> <a href="https://ko-fi.com/O5O0FG195"><img src="https://img.shields.io/badge/%E2%98%95-Buy%20me%20a%20coffee-red" /></a>

Official pihole docker with both DoT (DNS over TLS) and DoH (DNS over HTTPS) clients. Don't browse the web securely and yet still send your DNS queries in plain text!

## Usage:

For docker parameters, refer to [official pihole docker readme](https://github.com/pi-hole/pi-hole). Below is an docker compose example.

```
version: '3.0'

services:
  pihole:
    container_name: pihole-dot-doh
    image: devzwf/pihole-dot-doh:latest
    hostname: pihole1
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "82:80/tcp"
      - "10443:443/tcp"
    environment:
      TZ: 'America/Toronto'
      #WEBPASSWORD: 'password'
      DNS1: '127.1.1.1#5153'
      DNS2: '127.2.2.2#5253'
      #INTERFACE: 'br0'
      ServerIP: <IP of the docker host>
      ServerIPv6: ''
      IPv6: 'False'
      DNSMASQ_LISTENING: 'all'
    # Volumes store your data between container upgrades
    volumes:
      - './pihole/:/etc/pihole/'
      - './dnsmasq.d/:/etc/dnsmasq.d/'
      - './config/:/config'
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
```

### Notes:

- Remember to set pihole env DNS1 and DNS2 to use the DoH / DoT IP below. If either DNS1 or DNS2 is NOT set, Pihole will use a non-encrypted service.
  - DoH service (cloudflared) runs at 127.1.1.1#5153. Uses cloudflare (1.1.1.1 / 1.0.0.1) by default
  - DoT service (stubby) runs at 127.2.2.2#5253. Uses google (8.8.8.8 / 8.8.4.4) by default
  - To use just DoH or just DoT service, set both DNS1 and DNS2 to the same value.
- In addition to the 2 official paths, you can also map container /config to expose configuration yml files for cloudflared (cloudflared.yml) and stubby (stubby.yml).
  - Edit these files to add / remove services as you wish. The flexibility is yours.
- Credits:
  - Pihole base image is the official [pihole/pihole:latest](https://hub.docker.com/r/pihole/pihole/tags?page=1&name=latest)
  - Cloudflared client was obtained from [official site](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation#linux)
  - Stubby is a standard debian package
  - doh and dot was based from https://github.com/testdasi/pihole-dot-doh
  - update since other container was falling behind version

# Support

[![ko-fi](https://www.ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/devzwf)
