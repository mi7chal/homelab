# Migration Guide: Docker Swarm to Kubernetes (k3s)

This guide helps you migrate from the existing Docker Swarm setup to Kubernetes (k3s).

## Overview

The Kubernetes setup maintains feature parity with Docker Swarm while adapting to Kubernetes' architecture:
- Same services and configuration
- Same domain names (`.home`)
- Similar networking approach (VPN for specific services)
- Compatible with existing data and configurations

## Key Architectural Differences

| Aspect | Docker Swarm | Kubernetes (k3s) |
|--------|-------------|------------------|
| **Reverse Proxy** | Caddy Docker Proxy | Traefik Ingress |
| **Configuration** | docker-compose.yml + stack.env | ConfigMaps + Secrets + Manifests |
| **VPN Networking** | `network_mode: service:gluetun` | Sidecar containers in same pod |
| **Service Discovery** | Docker DNS | Kubernetes Services |
| **Volumes** | Named volumes + bind mounts | PVCs + hostPath |
| **Deployment** | `docker stack deploy` | `kubectl apply` |

## Pre-Migration Checklist

1. **Backup Your Data**
   ```bash
   # Backup configuration directories
   sudo tar czf homelab-backup-$(date +%Y%m%d).tar.gz /opt/docker/
   ```

2. **Document Current Configuration**
   - Note your VPN credentials from `servarr/stack.env`
   - Note Plex claim token from `plex/stack.env`
   - Note Cloudflare tunnel token from `net/stack.env`
   - Note any custom environment variables

3. **Install k3s**
   ```bash
   curl -sfL https://get.k3s.io | sh -
   # Configure kubectl
   mkdir -p ~/.kube
   sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
   sudo chown $USER ~/.kube/config
   ```

## Migration Steps

### Step 1: Configure Kubernetes Manifests

Transfer your configuration from Docker Swarm to Kubernetes:

1. **VPN Configuration** (from `servarr/stack.env`):
   - Update `k8s/servarr/secret.yaml` with your WireGuard keys
   - Update `k8s/servarr/configmap.yaml` with VPN settings

2. **Plex Configuration** (from `plex/stack.env`):
   - Update `k8s/plex/secret.yaml` with PLEX_CLAIM if used
   - Update `k8s/plex/configmap.yaml` with timezone and user IDs

3. **Network Configuration** (from `net/stack.env`):
   - Update `k8s/net/secret.yaml` with Cloudflare tunnel token
   - Update `k8s/net/configmap.yaml` with Tailscale routes

See [CONFIGURATION.md](CONFIGURATION.md) for detailed configuration instructions.

### Step 2: Stop Docker Swarm Services (Optional)

If migrating on the same host:

```bash
# Remove all stacks
docker stack rm servarr plex jellyfin tdarr net

# Wait for services to be removed
docker stack ls

# Optional: Leave swarm mode
docker swarm leave --force
```

### Step 3: Prepare Storage

The Kubernetes setup uses the same storage locations:
- Media files: `/mnt/media` (unchanged)
- Configuration: Can reuse existing `/opt/docker/` directories or let k3s create new ones

**Option A: Reuse Existing Configuration (Recommended for testing)**
```bash
# No changes needed - configs remain in /opt/docker/
# However, k3s will create new PVC directories by default
```

**Option B: Migrate Configuration to k3s Storage**
```bash
# After deploying, copy configs to PVC locations
# Example for sonarr:
kubectl get pvc -n homelab sonarr-config
# Find the actual directory in /var/lib/rancher/k3s/storage/
# Then copy: sudo cp -r /opt/docker/sonarr/config/* <pvc-directory>/
```

### Step 4: Deploy to Kubernetes

```bash
cd k8s
./deploy.sh
```

Or deploy manually:
```bash
kubectl apply -f k8s/base/
kubectl apply -f k8s/servarr/
kubectl apply -f k8s/plex/
kubectl apply -f k8s/jellyfin/
kubectl apply -f k8s/tdarr/
kubectl apply -f k8s/net/
```

### Step 5: Verify Deployment

```bash
# Check pods are running
kubectl get pods -n homelab -w

# Check VPN connection
kubectl logs -n homelab -l app=gluetun-servarr -c gluetun

# Check services
kubectl get svc -n homelab

# Check ingress
kubectl get ingress -n homelab
```

### Step 6: Test Services

Access each service via its `.home` domain and verify:
- [ ] qBittorrent working and using VPN IP
- [ ] Sonarr accessible and configured
- [ ] Radarr accessible and configured
- [ ] Prowlarr accessible and configured
- [ ] Bazarr accessible and configured
- [ ] Overseerr accessible
- [ ] Plex accessible and streaming works
- [ ] Tautulli tracking Plex activity
- [ ] Jellyfin accessible and streaming works
- [ ] Tdarr accessible
- [ ] AdGuard Home accessible

## Rollback Plan

If you need to rollback to Docker Swarm:

1. **Stop Kubernetes deployments**:
   ```bash
   cd k8s
   ./cleanup.sh
   ```

2. **Redeploy Docker Swarm**:
   ```bash
   docker swarm init
   docker stack deploy -c net/compose.yml --env-file net/stack.env net
   docker stack deploy -c servarr/compose.yml --env-file servarr/stack.env servarr
   docker stack deploy -c plex/compose.yml --env-file plex/stack.env plex
   docker stack deploy -c jellyfin/compose.yml --env-file jellyfin/stack.env jellyfin
   docker stack deploy -c tdarr/compose.yml --env-file tdarr/stack.env tdarr
   ```

3. **Restore configurations if needed**:
   ```bash
   sudo tar xzf homelab-backup-*.tar.gz -C /
   ```

## Troubleshooting

### Pods Not Starting

```bash
# Describe pod to see events
kubectl describe pod -n homelab <pod-name>

# Check logs
kubectl logs -n homelab <pod-name> -c <container-name>
```

### VPN Not Connecting

```bash
# Check Gluetun logs
kubectl logs -n homelab -l app=gluetun-servarr -c gluetun --tail=100

# Common issues:
# - Incorrect VPN credentials in secret
# - Missing NET_ADMIN capability
# - /dev/net/tun not accessible
```

### Services Not Accessible

```bash
# Check if Traefik is running (k3s default)
kubectl get pods -n kube-system | grep traefik

# Check ingress configuration
kubectl describe ingress -n homelab <service-name>-ingress

# Verify DNS resolution
# Ensure *.home domains point to your k3s node IP
```

### Configuration Not Persisting

```bash
# Check PVCs are bound
kubectl get pvc -n homelab

# Check mount points in pod
kubectl exec -n homelab <pod-name> -- ls -la /config
```

## Post-Migration

Once migration is successful:
1. Update your documentation with k8s-specific details
2. Set up monitoring if desired (Prometheus + Grafana)
3. Configure automated backups for PVC data
4. Consider setting up GitOps (Flux/ArgoCD) for configuration management

## Benefits of Kubernetes

After migration, you'll benefit from:
- Better resource management and scheduling
- Built-in health checks and self-healing
- Easier scaling and updates
- Industry-standard tooling and practices
- Better separation of configuration (ConfigMaps/Secrets)
- Native support for rolling updates

## Questions?

See [k8s/README.md](README.md) for detailed deployment documentation or [CONFIGURATION.md](CONFIGURATION.md) for configuration details.
