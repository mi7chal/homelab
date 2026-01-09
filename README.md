# My homelab

Docker Swarm stack configurations for a complete homelab with media services and networking tools.

## Stacks

- **servarr**: Media management (Gluetun VPN, qBittorrent, Sonarr, Radarr, Prowlarr, Bazarr, Overseerr, FlareSolverr)
- **plex**: Plex Media Server and Tautulli
- **jellyfin**: Jellyfin media server
- **tdarr**: Media transcoding
- **net**: Networking (AdGuard Home, Caddy Docker Proxy, Tailscale, Cloudflared)

## Quick Start

```bash
# Initialize Swarm
docker swarm init

# Deploy networking stack first (creates proxy-net network)
docker stack deploy -c net/compose.yml --env-file net/stack.env net

# Then deploy other stacks
docker stack deploy -c servarr/compose.yml --env-file servarr/stack.env servarr
docker stack deploy -c plex/compose.yml --env-file plex/stack.env plex
docker stack deploy -c jellyfin/compose.yml --env-file jellyfin/stack.env jellyfin
docker stack deploy -c tdarr/compose.yml --env-file tdarr/stack.env tdarr
```

## Configuration

Each stack has a `stack.env` file. Update with your values before deployment.

## Service Domains

Services are accessible via `.home` domains through Caddy Docker Proxy (automatic configuration via labels):
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

## Network Architecture

- **proxy-net**: Shared overlay network for Caddy reverse proxy
- **Stack networks**: Private overlay networks per stack (servarr_net, plex_net, jellyfin_net, tdarr_net)
- **Host network**: Used by AdGuard Home and Tailscale for direct network access

## Notes

- Caddy Docker Proxy automatically configures routes using service labels
- AdGuard Home and Tailscale use host networking for direct network access
- Servarr services share overlay network with Gluetun VPN
- Critical network services pinned to manager nodes; media services can run anywhere
 