# Networking

Basic networking setup for my homelab

## Tailscale

Allows outside of home connections.

> [!IMPORTANT]
> Tailscale on Debian 13 may require additional iptables rules. Rules below may be used 
> with package `iptables-persistent`.
>
> ```bash
> iptables -I DOCKER-USER -i tailscale0 -j ACCEPT
> iptables -I DOCKER-USER -o tailscale0 -j ACCEPT
> ```
>

## Aguard

Serves as network DNS and DHCP.
