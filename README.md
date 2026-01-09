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

# Deploy a stack
docker stack deploy -c <stack>/compose.yml --env-file <stack>/stack.env <stack-name>
```

## Configuration

Each stack has a `stack.env` file. Update with your values before deployment.

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
 