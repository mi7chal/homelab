# Docker

In this repository Docker is responsible only for running most crucial services (like networking) or the ones that author wants to purposefully isolate from Kubernetes cluster (like services on external VPS).

For simple management Portainer is advised.

- **Networking**: Deployed under [./net](./net/compose.yaml) (AdGuard Home, Netbird, AdGuard Sync)
- **External VPS Services**: Deployed under [./vps](./vps/compose.yaml) (RustFS S3 storage, Termix management)

All `compose.yaml` files come with their own `stack.env` files that define environment variables. The default volumes path is set to `/opt/docker/<service_name>`, which is believed by the repo author to be the most convenient and universal location.
