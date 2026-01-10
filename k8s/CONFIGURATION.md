# Pre-Deployment Configuration Checklist

Before deploying the Kubernetes manifests, you must update the following configuration files with your actual values.

## Required Configuration Changes

### 1. Servarr Secrets (`k8s/servarr/secret.yaml`)

Replace the placeholder values with your actual VPN credentials:

```yaml
stringData:
  WIREGUARD_PRIVATE_KEY: "key"  # ← Replace with your actual WireGuard private key
  WIREGUARD_PRESHARED_KEY: "key"  # ← Replace with your actual WireGuard preshared key
  FIREWALL_OUTBOUND_SUBNETS: ""  # ← Optional: Add your local subnet (e.g., "192.168.0.0/24")
```

### 2. Plex Secrets (`k8s/plex/secret.yaml`)

If you want to claim your Plex server:

```yaml
stringData:
  PLEX_CLAIM: ""  # ← Optional: Add your Plex claim token from https://www.plex.tv/claim/
```

### 3. Network Secrets (`k8s/net/secret.yaml`)

Replace with your Cloudflare tunnel token:

```yaml
stringData:
  CLOUDFLARED_TUNNEL_TOKEN: "your_cloudflared_tunnel_token_here"  # ← Replace with your actual token
```

## Optional Configuration Changes

### 4. Servarr ConfigMap (`k8s/servarr/configmap.yaml`)

Review and adjust these settings if needed:

- `TZ`: Timezone (default: "Europe/Warsaw")
- `PUID` / `PGID`: User/Group IDs (default: "1000")
- `MEDIA_PATH`: Media directory path (default: "/mnt/media")
- `VPN_SERVICE_PROVIDER`: VPN provider (default: "windscribe")
- `WIREGUARD_ADDRESSES`: VPN IP address
- `DNS`: DNS server IP
- `SERVER_CITIES`: VPN server locations

### 5. Other ConfigMaps

Adjust timezone and user IDs in:
- `k8s/plex/configmap.yaml`
- `k8s/jellyfin/configmap.yaml`
- `k8s/tdarr/configmap.yaml`
- `k8s/net/configmap.yaml`

## Storage Requirements

Ensure the following directory exists on your k3s node:
- `/mnt/media` - This should contain your media files

The k3s local-path provisioner will automatically create directories for PersistentVolumeClaims, typically at:
- `/var/lib/rancher/k3s/storage/`

## DNS Configuration

For the `.home` domains to work, you need to configure your DNS server (e.g., AdGuard Home or your router) to point these domains to your k3s node's IP address:

- qbittorrent.home
- sonarr.home
- radarr.home
- prowlarr.home
- bazarr.home
- overseerr.home
- plex.home
- tautulli.home
- jellyfin.home
- tdarr.home
- adguard.home

## After Configuration

Once you've updated all the necessary files, deploy using:

```bash
cd k8s
./deploy.sh
```

Or manually:

```bash
kubectl apply -f k8s/base/
kubectl apply -f k8s/servarr/
kubectl apply -f k8s/plex/
kubectl apply -f k8s/jellyfin/
kubectl apply -f k8s/tdarr/
kubectl apply -f k8s/net/
```

## Verification

Check that all pods are running:

```bash
kubectl get pods -n homelab
```

All pods should eventually reach "Running" status. The Gluetun pod may take a minute to establish the VPN connection.
