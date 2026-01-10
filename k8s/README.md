# Kubernetes (k3s) Deployment Guide

This directory contains Kubernetes manifests for deploying the homelab services on k3s.

## Prerequisites

- k3s installed and running
- `kubectl` configured to connect to your k3s cluster
- Local storage provisioner (k3s comes with local-path by default)
- Media directory mounted at `/mnt/media` on your k3s node

## Architecture

### Gluetun VPN Network
The following services share the Gluetun VPN network namespace (sidecar pattern):
- qBittorrent
- Sonarr
- Radarr
- Prowlarr
- Bazarr
- FlareSolverr

All these services run in a single pod, sharing Gluetun's VPN connection.

### Other Services
- **Overseerr**: Standalone deployment (not using VPN)
- **Plex & Tautulli**: Media server and monitoring
- **Jellyfin**: Alternative media server
- **Tdarr**: Media transcoding
- **Network Services**: AdGuard Home, Tailscale, Cloudflared

### Ingress
k3s comes with Traefik by default, which replaces Caddy from the Docker Swarm setup. All services are exposed via Ingress resources with `.home` domain names.

## Configuration

Before deploying, you need to update the following files with your actual values:

### Secrets
1. **Servarr secrets** (`k8s/servarr/secret.yaml`):
   - `WIREGUARD_PRIVATE_KEY`: Your WireGuard private key
   - `WIREGUARD_PRESHARED_KEY`: Your WireGuard preshared key

2. **Plex secrets** (`k8s/plex/secret.yaml`):
   - `PLEX_CLAIM`: Your Plex claim token (optional)

3. **Network secrets** (`k8s/net/secret.yaml`):
   - `CLOUDFLARED_TUNNEL_TOKEN`: Your Cloudflare tunnel token

### ConfigMaps
You may need to adjust values in:
- `k8s/servarr/configmap.yaml` - VPN settings, timezone, user IDs
- `k8s/plex/configmap.yaml` - Timezone, user IDs
- `k8s/jellyfin/configmap.yaml` - Timezone, user IDs, published URL
- `k8s/tdarr/configmap.yaml` - Timezone, user IDs, Tdarr settings
- `k8s/net/configmap.yaml` - Timezone, Tailscale routes

## Deployment Order

Deploy in the following order:

### 1. Create Namespace
```bash
kubectl apply -f k8s/base/namespace.yaml
```

### 2. Deploy Network Services (Optional, if needed)
```bash
kubectl apply -f k8s/net/configmap.yaml
kubectl apply -f k8s/net/secret.yaml
kubectl apply -f k8s/net/pvcs.yaml
kubectl apply -f k8s/net/adguard-deployment.yaml
kubectl apply -f k8s/net/tailscale-deployment.yaml
kubectl apply -f k8s/net/cloudflared-deployment.yaml
```

### 3. Deploy Servarr Stack (with Gluetun VPN)
```bash
kubectl apply -f k8s/servarr/configmap.yaml
kubectl apply -f k8s/servarr/secret.yaml
kubectl apply -f k8s/servarr/pvcs.yaml
kubectl apply -f k8s/servarr/gluetun-deployment.yaml
kubectl apply -f k8s/servarr/service.yaml
kubectl apply -f k8s/servarr/ingress.yaml
kubectl apply -f k8s/servarr/overseerr.yaml
```

### 4. Deploy Plex Stack
```bash
kubectl apply -f k8s/plex/configmap.yaml
kubectl apply -f k8s/plex/secret.yaml
kubectl apply -f k8s/plex/pvcs.yaml
kubectl apply -f k8s/plex/plex-deployment.yaml
kubectl apply -f k8s/plex/tautulli-deployment.yaml
```

### 5. Deploy Jellyfin
```bash
kubectl apply -f k8s/jellyfin/configmap.yaml
kubectl apply -f k8s/jellyfin/pvcs.yaml
kubectl apply -f k8s/jellyfin/jellyfin-deployment.yaml
```

### 6. Deploy Tdarr
```bash
kubectl apply -f k8s/tdarr/configmap.yaml
kubectl apply -f k8s/tdarr/pvcs.yaml
kubectl apply -f k8s/tdarr/tdarr-deployment.yaml
```

## Quick Deploy All

```bash
# Deploy everything at once
kubectl apply -f k8s/base/
kubectl apply -f k8s/net/
kubectl apply -f k8s/servarr/
kubectl apply -f k8s/plex/
kubectl apply -f k8s/jellyfin/
kubectl apply -f k8s/tdarr/
```

## Accessing Services

Services are accessible via the following domain names (configured in your DNS):
- http://qbittorrent.home - qBittorrent (via VPN)
- http://sonarr.home - Sonarr (via VPN)
- http://radarr.home - Radarr (via VPN)
- http://prowlarr.home - Prowlarr (via VPN)
- http://bazarr.home - Bazarr (via VPN)
- http://overseerr.home - Overseerr
- http://plex.home - Plex Media Server
- http://tautulli.home - Tautulli
- http://jellyfin.home - Jellyfin
- http://tdarr.home - Tdarr
- http://adguard.home - AdGuard Home

## Persistent Storage

All persistent volumes use the `local-path` storage class (k3s default). Data is stored according to the PVC definitions:
- Configuration data: Stored in PVCs (typically at `/var/lib/rancher/k3s/storage/`)
- Media files: Direct host path mount (`/mnt/media`)

## Troubleshooting

### Check pod status
```bash
kubectl get pods -n homelab
```

### View pod logs
```bash
kubectl logs -n homelab <pod-name> -c <container-name>
```

### Check Gluetun VPN connection
```bash
kubectl logs -n homelab $(kubectl get pod -n homelab -l app=gluetun-servarr -o jsonpath='{.items[0].metadata.name}') -c gluetun
```

### Check service endpoints
```bash
kubectl get endpoints -n homelab
```

### Check ingress
```bash
kubectl get ingress -n homelab
```

## Migration from Docker Swarm

The Docker Swarm compose files are retained for reference. Key differences:
- **Networking**: Gluetun VPN uses sidecar pattern instead of `network_mode: service:gluetun`
- **Reverse Proxy**: Traefik (k3s default) replaces Caddy Docker Proxy
- **Labels**: Ingress annotations replace Caddy labels
- **Placement**: k3s scheduler handles pod placement (no explicit node constraints needed)
- **Storage**: PVCs replace host path volumes for configuration data

## Notes

- Portainer is not included in these manifests (user manages separately)
- Hardware acceleration (GPU) is enabled for Plex, Jellyfin via `/dev/dri` device mount
- Services requiring host networking (AdGuard, Tailscale) use `hostNetwork: true`
- The Gluetun pod requires `NET_ADMIN` capability for VPN functionality
