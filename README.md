# My homelab

Complete homelab configurations for media services and networking tools.

## Deployment Options

### Kubernetes (k3s) - Recommended
Kubernetes manifests for k3s deployment. See [k8s/README.md](k8s/README.md) for detailed instructions.

### Docker Swarm (Legacy)
Original Docker Swarm stack configurations are retained in the stack directories.

## Stacks

- **servarr**: Media management (Gluetun VPN, qBittorrent, Sonarr, Radarr, Prowlarr, Bazarr, Overseerr, FlareSolverr)
- **plex**: Plex Media Server and Tautulli
- **jellyfin**: Jellyfin media server
- **tdarr**: Media transcoding
- **net**: Networking (AdGuard Home, Tailscale, Cloudflared)

## Quick Start

### Kubernetes (k3s)

```bash
# Update secrets and configuration in k8s/ directory first
# Then apply all manifests:
kubectl apply -f k8s/base/
kubectl apply -f k8s/servarr/
kubectl apply -f k8s/plex/
kubectl apply -f k8s/jellyfin/
kubectl apply -f k8s/tdarr/
kubectl apply -f k8s/net/
```

See [k8s/README.md](k8s/README.md) for detailed deployment instructions.

### Docker Swarm (Legacy)

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

### Kubernetes
Update ConfigMaps and Secrets in the `k8s/` directory before deployment. See [k8s/README.md](k8s/README.md).

### Docker Swarm
Each stack has a `stack.env` file. Update with your values before deployment.

## Service Domains

Services are accessible via `.home` domains:
- **Kubernetes**: Through Traefik Ingress (k3s default)
- **Docker Swarm**: Through Caddy Docker Proxy (automatic configuration via labels)

Available services:
- overseerr.home
- plex.home
- tautulli.home
- jellyfin.home
- tdarr.home
- qbittorrent.home (via VPN)
- sonarr.home (via VPN)
- radarr.home (via VPN)
- prowlarr.home (via VPN)
- bazarr.home (via VPN)
- adguard.home

## Network Architecture

### Kubernetes (k3s)
- **VPN**: Gluetun VPN using sidecar pattern (all containers in pod share network namespace)
- **Services using VPN**: qBittorrent, Sonarr, Radarr, Prowlarr, Bazarr, FlareSolverr
- **Ingress**: Traefik (k3s default) for HTTP routing
- **Host network**: Used by AdGuard Home and Tailscale for direct network access

### Docker Swarm (Legacy)
- **proxy-net**: Shared overlay network for Caddy reverse proxy
- **Stack networks**: Private overlay networks per stack (servarr_net, plex_net, jellyfin_net, tdarr_net)
- **Host network**: Used by AdGuard Home and Tailscale for direct network access

## Notes

### Kubernetes
- Traefik Ingress controller handles HTTP routing (replaces Caddy)
- Gluetun VPN uses sidecar pattern - all servarr services run in one pod
- PersistentVolumeClaims for configuration, host paths for media
- Hardware acceleration enabled for Plex and Jellyfin via `/dev/dri`

### Docker Swarm
- Caddy Docker Proxy automatically configures routes using service labels
- AdGuard Home and Tailscale use host networking for direct network access
- Servarr services share overlay network with Gluetun VPN
- Critical network services pinned to manager nodes; media services can run anywhere
 