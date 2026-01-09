# My homelab

Docker Swarm stack configurations for a complete homelab with media services and networking tools.

## Stacks

- **servarr**: Media management (Gluetun VPN, qBittorrent, Sonarr, Radarr, Prowlarr, Bazarr, Overseerr, FlareSolverr)
- **plex**: Plex Media Server and Tautulli
- **jellyfin**: Jellyfin media server
- **tdarr**: Media transcoding
- **net**: Networking (AdGuard Home, Caddy, Tailscale, Cloudflared)

## Quick Start

```bash
# Initialize Swarm
docker swarm init

# Deploy networking stack first (creates networks for other services)
docker stack deploy -c net/compose.yml --env-file net/stack.env net

# Then deploy other stacks
docker stack deploy -c servarr/compose.yml --env-file servarr/stack.env servarr
docker stack deploy -c plex/compose.yml --env-file plex/stack.env plex
docker stack deploy -c jellyfin/compose.yml --env-file jellyfin/stack.env jellyfin
docker stack deploy -c tdarr/compose.yml --env-file tdarr/stack.env tdarr
```

## Configuration

Each stack has a `stack.env` file. Update with your values before deployment.

Create `/opt/docker/caddy/Caddyfile` using the provided `net/Caddyfile.example` template.

## Service Domains

Services are accessible via `.home` domains through Caddy reverse proxy:
- overseerr.home
- plex.home
- tautulli.home
- jellyfin.home
- tdarr.home
- qbittorrent.home
- sonarr.home
- radarr.home
- prowlarr.home
- bazarr.home

## Notes

- AdGuard Home and Tailscale use `network_mode: host` for direct network access
- Servarr services share overlay network with Gluetun VPN
- Media services can run on any node; critical network services pinned to manager nodes
 