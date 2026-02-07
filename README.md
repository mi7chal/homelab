# Homelab

[![FluxCD](https://img.shields.io/badge/GitOps-FluxCD-blue?style=for-the-badge&logo=flux)](https://fluxcd.io/)
[![K3s](https://img.shields.io/badge/Orchestration-K3s-orange?style=for-the-badge&logo=kubernetes)](https://k3s.io/)
[![PostgreSQL](https://img.shields.io/badge/Database-CloudNativePG-336791?style=for-the-badge&logo=postgresql)](https://cloudnative-pg.io/)
[![Security](https://img.shields.io/badge/Secrets-SOPS-green?style=for-the-badge&logo=locklizard)](https://github.com/getsops/sops)

Welcome to my digital workshop. This repository manages the heart of my home network—from high-level automation to low-level DNS infrastructure. It is built on the philosophies of total privacy, open-source purity, and the pursuit of clean, declarative infrastructure.

---

## 🏗 System Architecture

I follow a hybrid approach to ensure high availability for core services while maintaining flexibility for experiments.

### ⚓ Core Networking (The Foundation)
Managed via Docker Compose for "Life Support" services. These run independently of the Kubernetes cluster to ensure that if the cluster goes down, the house still has internet, DNS, and remote access.
- 🛡️ **[AdGuardHome](https://adguard.com/adguardhome.html)**: Network-wide ad & tracker blocking with DNS-over-HTTPS.
- 🌌 **[Tailscale](https://tailscale.com/)**: WireGuard-based mesh VPN for secure, zero-config remote access.
- 🔄 **AdGuard Sync**: Ensures DNS consistency across multiple nodes.

### ☸️ The Command Center (The Cluster)
Everything else is managed declaratively via GitOps. If it's in this repo, it's on the cluster.
- **GitOps**: [FluxCD](https://fluxcd.io/) for continuous, automated reconciliation.
- **Ingress**: [Traefik](https://traefik.io/) paired with Cloudflared tunnels for secure, zero-entrypoint external access.
- **Storage**: [Longhorn](https://longhorn.io/) for distributed, replicated block storage across nodes.
- **Identity**: [Authentik](https://goauthentik.io/) as the centralized OIDC/SAML provider (The Gatekeeper).
- **Database**: [CloudNativePG](https://cloudnative-pg.io/) managing production-grade PostgreSQL clusters with automated backups.

---

## 🏠 Hardware Foundation

| Machine | Role | CPU | RAM | Storage | OS |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **GMKtec NucBox G3** | Main Compute | Intel N100 | 16GB | 1TB NVMe | Proxmox VE |
| **Raspberry Pi 5** | Network Edge | BCM2712 | 4GB | 128GB SSD | RPi OS Lite |

---

## 🚀 The Living Room (Applications)

- 🎬 **Entertainment**: [Jellyfin](https://jellyfin.org/) for private streaming & [Jellyseerr](https://jellyseerr.dev/) for content requests.
- 🤖 **Automation**: [n8n](https://n8n.io/) - The low-code workflow engine connecting my digital life.
- 📥 **Media Stack**: Fully automated pipeline for content acquisition and management.
- 🔑 **Auth**: Every service is guarded by **Authentik** with MFA and Passkey support.

---

## 🔐 Security & Operations

- **Encryption**: All sensitive data is encrypted at rest using **SOPS** and **Age**. No cleartext secrets ever touch Git.
- **Privacy**: No external cloud dependencies (except for Cloudflare Tunnels). Data stays on my silicon.
- **Consistency**: Automated `encrypt-secrets.sh` script to ensure safety before every commit.

### 🛠 Quick Commands
```bash
# Encrypt all secrets before committing
./encrypt-secrets.sh
```

---

## 📜 Philosophy
1. **Overkill is a Feature**: If it can be automated, it will be. If it can be redundant, it is.
2. **Open Source Only**: I prefer FOSS that respects user autonomy and privacy.
3. **Cleanliness**: Infrastructure as Code (IaC) or it didn't happen.
4. **Privacy**: My data is my own. No exceptions.

---
