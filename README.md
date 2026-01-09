# My homelab

This repository contains Docker Swarm stack configurations for running a complete homelab setup with media services, networking tools, and monitoring.

## Prerequisites

- Docker installed on your system
- Docker Swarm initialized (`docker swarm init`)
- Required directories created under `/opt/docker/` for each service
- Media storage mounted at `/mnt/media` (or adjust `MEDIA_PATH` in env files)

## Services

### Servarr Stack
- **Gluetun**: VPN client for secure torrenting
- **qBittorrent**: BitTorrent client
- **Sonarr**: TV show management
- **Radarr**: Movie management
- **Prowlarr**: Indexer manager
- **Bazarr**: Subtitle management
- **Overseerr**: Media request management
- **Flaresolverr**: Cloudflare bypass

### Plex Stack
- **Plex Media Server**: Media streaming server
- **Tautulli**: Plex monitoring and statistics

### Jellyfin Stack
- **Jellyfin**: Open-source media server

### Tdarr Stack
- **Tdarr**: Media transcoding automation

### Net Stack
- **AdGuard Home**: Network-wide ad blocking
- **Nginx Proxy Manager**: Reverse proxy with SSL
- **Tailscale**: VPN mesh network
- **Cloudflared**: Cloudflare tunnel

## Deployment

### Initialize Docker Swarm

If you haven't already initialized Docker Swarm:

```bash
docker swarm init
```

### Configure Environment Variables

Each stack has its own `stack.env` file with required configuration. Update these files with your specific values:

- `servarr/stack.env`: VPN credentials, media paths, user IDs
- `plex/stack.env`: Plex claim token, media paths
- `jellyfin/stack.env`: Media paths, published server URL
- `tdarr/stack.env`: Media paths
- `net/stack.env`: Tailscale routes, Cloudflare tunnel token

### Deploy Stacks

Deploy each stack using the `docker stack deploy` command:

```bash
# Deploy servarr stack (media management)
docker stack deploy -c servarr/compose.yml --env-file servarr/stack.env servarr

# Deploy plex stack
docker stack deploy -c plex/compose.yml --env-file plex/stack.env plex

# Deploy jellyfin stack
docker stack deploy -c jellyfin/compose.yml --env-file jellyfin/stack.env jellyfin

# Deploy tdarr stack
docker stack deploy -c tdarr/compose.yml --env-file tdarr/stack.env tdarr

# Deploy networking stack
docker stack deploy -c net/compose.yml --env-file net/stack.env net
```

### Verify Deployment

Check the status of your stacks:

```bash
# List all stacks
docker stack ls

# View services in a specific stack
docker stack services servarr
docker stack services plex
docker stack services jellyfin
docker stack services tdarr
docker stack services net

# View service logs
docker service logs <service-name>
```

## Management

### Update a Stack

To update a stack after making changes to the compose file:

```bash
docker stack deploy -c <stack>/compose.yml --env-file <stack>/stack.env <stack-name>
```

### Remove a Stack

```bash
docker stack rm <stack-name>
```

### Scale Services

To scale a service (if needed):

```bash
docker service scale <stack-name>_<service-name>=<replicas>
```

## Port Mapping

### Servarr Stack
- 9095: qBittorrent WebUI
- 6881: qBittorrent (TCP/UDP)
- 7878: Radarr
- 8989: Sonarr
- 9696: Prowlarr
- 6767: Bazarr
- 5055: Overseerr
- 8191: Flaresolverr

### Plex Stack
- 32400: Plex Media Server
- 8181: Tautulli

### Jellyfin Stack
- 8096: Jellyfin WebUI

### Tdarr Stack
- 8265: Tdarr WebUI
- 8266: Tdarr Server

### Net Stack
- 53: AdGuard Home DNS (TCP/UDP)
- 3000: AdGuard Home WebUI
- 80/443: Nginx Proxy Manager
- 81: Nginx Proxy Manager WebUI

## Notes

- All services are configured to run on manager nodes only
- Overlay networks are used for service communication
- Services that require host networking (AdGuard Home, Tailscale) use host-mode port publishing
- Device access (GPU for transcoding) is configured for Plex and Jellyfin
- VPN routing through Gluetun is handled via shared network for servarr services

## Troubleshooting

### Service Won't Start

Check service logs:
```bash
docker service logs <stack-name>_<service-name>
```

### Network Issues

Verify overlay networks:
```bash
docker network ls
docker network inspect <network-name>
```

### Volume Permissions

Ensure the PUID/PGID in env files match your user:
```bash
id -u  # Get PUID
id -g  # Get PGID
```

### Stack Update Not Applying

Force update a service:
```bash
docker service update --force <stack-name>_<service-name>
``` 