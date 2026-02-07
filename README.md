# Homelab

This project is a GitOps configuration of my homelab (self-hosted servers at my home). 

It is based on Kubernetes (K3s) and Docker. Docker is used for core networking (DNS, DHCP, VPN etc.) and K3s is used for apps/services.

> **What is Homelab?**
> 
> A homelab is a personal home network with server (or servers) and services running on it. Typically it is destined to learn, > experiment and host personal services. Now it becames popular to also host AI agents, which are perfect example of homelabing but ?> this repo is focused on standard infrastracture. Full definition and community may be found on [r/homelab](https://www.reddit.com/r/homelab/).

## Project goals and ideas
to be added

## Tech stack summary

<!-- Tech Stack -->
[![FluxCD](https://img.shields.io/badge/GitOps-FluxCD-blue?style=for-the-badge&logo=flux)](https://fluxcd.io/)
[![K3s](https://img.shields.io/badge/Orchestration-K3s-orange?style=for-the-badge&logo=kubernetes)](https://k3s.io/)
[![Proxmox](https://img.shields.io/badge/Proxmox-E57000?style=for-the-badge&logo=proxmox&logoColor=white)](https://www.proxmox.com/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/Database-CloudNativePG-336791?style=for-the-badge&logo=postgresql)](https://cloudnative-pg.io/)
[![Security](https://img.shields.io/badge/Secrets-SOPS-green?style=for-the-badge&logo=locklizard)](https://github.com/getsops/sops)
[![Tailscale](https://img.shields.io/badge/Tailscale-18181B?style=for-the-badge&logo=tailscale&logoColor=white)](https://tailscale.com/)
[![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?style=for-the-badge&logo=cloudflare&logoColor=white)](https://www.cloudflare.com/)
[![Traefik](https://img.shields.io/badge/Traefik-24A1C1?style=for-the-badge&logo=traefik&logoColor=white)](https://traefik.io/)
[![Pre-Commit](https://img.shields.io/badge/pre--commit-FAB040?style=for-the-badge&logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=fff)](#)
[![Oracle Cloud](https://custom-icon-badges.demolab.com/badge/Oracle%20Cloud-F80000?logo=oracle&logoColor=white)](#)


## Infrastructure

### Core Networking
Managed via Docker Compose to ensure stability and independence from the k8s.

- **AdGuard DNS**: DNS server with ad and tracker blocking.
- **Tailscale**: WireGuard-based mesh VPN for remote access.
- **AdGuard Sync**: Small service for synchronizing AdGuard DNS settings across multiple nodes.

### Kubernetes Cluster
Managed declaratively via FluxCD.
- **GitOps**: [FluxCD](https://fluxcd.io/)
- **Ingress**: [Traefik](https://traefik.io/) with Cloudflared tunnels
- **Storage**: [Longhorn](https://longhorn.io/)
- **Identity**: [Authentik](https://goauthentik.io/) (OIDC/SAML provider)
- **Database**: [CloudNativePG](https://cloudnative-pg.io/)

## Hardware

| Machine | Role | CPU | RAM | Storage | OS |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GMKtec NucBox G3** | Main Compute | Intel N100 | 16GB | 1TB NVMe | Proxmox VE |
| **Raspberry Pi 5** | Network Edge | BCM2712 | 4GB | 128GB SSD | RPi OS Lite |

## Applications

- **Media**: [Jellyfin](https://jellyfin.org/) and [Jellyseerr](https://jellyseerr.dev/)
- **Automation**: [n8n](https://n8n.io/)
- **Media Stack**: Automated content acquisition
- **Auth**: Authentik with MFA and Passkey support

## Security & Operations

- **Secrets**: Encrypted at rest using **SOPS** and **Age**.
- **Privacy**: Self-hosted services with minimal external dependencies.

### Quick Commands

```bash
# Encrypt all secrets before committing
./encrypt-secrets.sh
```
