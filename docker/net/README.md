# Networking

Basic networking setup for my homelab

## Netbird

Allows outside of home connections.

> [!IMPORTANT]
> Netbird on Debian 13 may require additional iptables rules. Rules below may be used 
> with package `iptables-persistent`.
>   
> ```bash
> iptables -I DOCKER-USER -i ntb -j ACCEPT
> iptables -I DOCKER-USER -o ntb -j ACCEPT
> ```
>

## AdGuard

Serves as network DNS and DHCP.
