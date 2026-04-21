# Homelab

This project is a GitOps configuration of a home server infrastructure. It contains services for smart home, media, automations, data storage, and more. It is not only a template, but a fully working configuration that can be adopted by anyone with access to a personal server or servers. This repo is deployed and actively used by the author, and is regularly updated and maintained. It follows best practices that work well for the author, but may not suit everyone.

If you want to use this project as a template, go to the [deployment section](#deployment).

<details>
<summary><strong>What is a Homelab?</strong></summary>

A homelab is a personal home network with one or more servers and services running on it. It is typically used for learning, experimenting, and hosting personal services. Hosting AI agents has recently become popular in the homelab community, but this repo is focused on standard infrastructure. A full definition and a vibrant community can be found on [r/homelab](https://www.reddit.com/r/homelab/).

</details>

## Overview

This repo contains two main modules — Docker and Kubernetes. Docker is used for core services that the whole network depends on, or for services hosted externally. Kubernetes is used for everything else.

The diagram below provides a simplified overview of this repo's architecture.

![Software Architecture Schema](docs/images/software_schema.png)

For more information on why this may seem overkill, go to [Philosophy and Rules](#philosophy-and-rules).

### Core Services

Core (Docker) services are kept in the [Docker folder](docker).

> [!NOTE]
> These services must be deployed manually (see the [deployment section](#deployment)). The author manages them using Portainer, but this is optional.

These services include mostly networking (DNS, DHCP, VPN, etc.). For more details, see the [Docker README](docker/README.md).

### External Services

Since it is strongly advised not to store backups or critical data on home servers, some services are hosted externally. Currently, the author uses S3 storage hosted on an [OCI VPS](https://www.oracle.com/cloud/) running [RustFS](https://rustfs.com).

The VPS is connected to the home network using Netbird, which allows it to be managed from self-hosted Portainer and exposes its services only within the homelab network.

> [!NOTE]
> The VPS does not belong to the Kubernetes cluster. It is strongly advised against adding a VPS to a self-hosted Kubernetes cluster, especially one using Longhorn.

> [!WARNING]
> Connecting a VPS to a home network via VPN has security implications and should be carefully considered. The author strictly prevents the VPS from accessing homelab servers via Netbird Access Control. The VPS also has its own strict firewall rules.

### Kubernetes Cluster

The Kubernetes cluster is the heart of this homelab — it is the default place where services and apps live. For simplicity and resource efficiency, it is managed declaratively (using this repo) via FluxCD.

> [!NOTE]
> This repo's implementation uses K3S as the Kubernetes distribution, but other distributions (K0S, K8S, MicroK8s, etc.) may be used as well.

Thanks to the GitOps approach, services are deployed and updated automatically. Almost the complete cluster configuration is stored in this repo, including encrypted secrets. Kubernetes ensures stability and high uptime.

The cluster uses Traefik as the ingress controller and Longhorn for storage and data replication. For more specific infrastructure details, see the [Kubernetes README](k8s/README.md).

> [!TIP]
> **Alternatives**
>
> There is an excellent alternative to FluxCD — ArgoCD. It is more popular, but in home networks it may be too heavy and complex. FluxCD was chosen for this repo due to its simplicity and low resource footprint.
>
> Docker Swarm is also an alternative to Kubernetes, but it was not chosen here because the author outgrew its limitations and wanted more control over service management.

## Philosophy and Rules

This project is built to be as stable and reliable as possible, while also being easy to manage and update. It may seem like overkill for most homelabs, but using Kubernetes has advantages that may not be immediately obvious. These advantages are listed below.

- **Firstly, versioning.** In Kubernetes, image updates are automatic. The author specifies a version range (e.g. `1.2.x`) and patches are applied automatically. There is no need to manually update images. For major updates, it is good practice to update the version manually and test the changes, though this is not enforced for every service individually.

- **Secondly, stability and reliability.** In Kubernetes, pods can be restarted or rebuilt automatically on failure. Some pods (like Cloudflare tunnels) can run on multiple nodes, which ensures high availability.

- **Thirdly, data integrity and safety.** Longhorn ensures each service's data is stored redundantly on at least two devices and backed up to external S3 storage. All of this is automated and centrally managed.

- **Fourthly, flexibility.** In Kubernetes, applications are automatically distributed across nodes based on available resources. Specific services can be pinned to nodes, but for most workloads, automatic distribution is more convenient and allows scaling (e.g. adding more servers) without manually migrating services.

- **Fifthly, centralised management and monitoring.** Kubernetes with FluxCD enables automatic, declarative deployment for the entire cluster. This means all services can be updated without any direct access to the server — just by updating this repo.

- **Sixthly, secrets management.** Kubernetes allows secrets to be encrypted and stored in this repository, making it secure while also simplifying secret rotation without requiring direct server access.

- **Seventhly, security.** Security in Kubernetes is more advanced than in Docker. It allows granular control over network access and resource usage. Traefik (the reverse proxy) is seamlessly integrated with the cluster and enables easy and secure service exposure.

## Applications

This repository can be used as a template for hosting various applications. The author uses it to host media (Jellyfin), automations (N8N), data storage (Postgres), and more. For details on deploying apps, see the [Kubernetes README](k8s/README.md).

## Security, Durability and Reliability

Since self-hosting is often chosen for privacy and control, ensuring security, durability, and reliability was one of the main goals of this project. Below is a detailed explanation of the problems encountered and the solutions applied.

### Backups

Data loss can happen (for example due to SSD failures), and in home environments data is usually not replicated the way it is in the cloud. To address this, all data in this repo is stored on Longhorn volumes, which are replicated across at least two devices. Additionally, data is backed up to external S3 storage (hosted by the author on an external VPS) and can be easily restored.

The author also hosts Home Assistant (not included in this repo), which is backed up to Google Drive using the [hassio-google-drive-backup](https://github.com/sabeechen/hassio-google-drive-backup) plugin.

### Secrets Management

Secrets for the Kubernetes cluster are stored and encrypted using SOPS and Age. They are asymmetrically encrypted, pushed to this repo, and decrypted only on the cluster. This approach is safe, simple, and convenient.

### Updates and Versions

All versions of apps and services are carefully chosen for stability and security. The recommended approach is to specify only the major and minor version (e.g. `1.2.x` for Kubernetes, `1.2` for Docker), which allows automatic patch updates while preventing breaking changes from major releases. For more details, see [Philosophy and Rules](#philosophy-and-rules).

Some critical services should be pinned to an explicit version (e.g. Traefik) to prevent unexpected changes. Others that are in early development with frequent releases may be set to `latest` (e.g. N8N).

### Monitoring

The author prefers a lightweight monitoring setup over heavy tooling, so only a minimal stack is used. It includes the Traefik dashboard, Portainer, Longhorn UI, Kubernetes Metrics Server, Home Assistant statistics, and Netweave.

Using tools like Uptime Kuma is also an excellent choice, but this repo focuses on a lightweight and essential stack.

## Development Workflow

This repo follows a standard Git workflow. The author uses a single `main` branch, which is typical for small GitOps environments without separate development and staging environments.

A few tools are used to make the workflow safer, easier, and more convenient.

### Prek (Pre-Commit)

Before every commit, [Prek](https://prek.j178.dev) is run to check YAML syntax, validate Kubernetes secrets, and more.

### Quick Commands

The author created a script for encrypting secrets. Secret files are named `name.secret.yaml` and are automatically encrypted to `name-secret.enc.yaml` using the script below. This simplifies the workflow and ensures secrets are always encrypted before committing.

```bash
# Encrypt all secrets before committing
./encrypt-secrets.sh
```

## Tech Stack Summary

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![FluxCD](https://img.shields.io/badge/FluxCD-5468FF?logo=flux&logoColor=white)
![Proxmox](https://img.shields.io/badge/Proxmox-E57000?logo=proxmox&logoColor=white)
![Debian](https://img.shields.io/badge/Debian-A81D33?logo=debian&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-4169E1?logo=postgresql&logoColor=white)
![CloudNativePG](https://img.shields.io/badge/CloudNativePG-4456F7?logo=postgresql&logoColor=white)
![SOPS](https://img.shields.io/badge/SOPS-4B5563?logo=mozilla&logoColor=white)
![Age](https://img.shields.io/badge/Age-111827?logo=letsencrypt&logoColor=white)
![Netbird](https://img.shields.io/badge/Netbird-00B3FF?logo=wireguard&logoColor=white)
![Cloudflare](https://img.shields.io/badge/Cloudflare-F38020?logo=cloudflare&logoColor=white)
![Traefik](https://img.shields.io/badge/Traefik-24A1C1?logo=traefikmesh&logoColor=white)
![Pre-Commit](https://img.shields.io/badge/Pre--Commit-FAB040?logo=pre-commit&logoColor=black)
![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=white)
![Oracle Cloud](https://img.shields.io/badge/Oracle%20Cloud-F80000?logo=oracle&logoColor=white)
![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-C51A4A?logo=raspberrypi&logoColor=white)
![RustFS](https://img.shields.io/badge/RustFS-000000?logo=rust&logoColor=white)
![N8N](https://img.shields.io/badge/N8N-EA4B71?logo=n8n&logoColor=white)
![Authentik](https://img.shields.io/badge/Authentik-FD4B2D?logo=auth0&logoColor=white)
![Longhorn](https://img.shields.io/badge/Longhorn-00AEEF?logo=kubernetes&logoColor=white)
![MetalLB](https://img.shields.io/badge/MetalLB-2A5CAA?logo=kubernetes&logoColor=white)
![AdGuard](https://img.shields.io/badge/AdGuard-68BC71?logo=adguard&logoColor=white)

## Hardware

This section focuses not only on the software infrastructure but also on the author's specific deployment. It is included to give a broader picture and additional context.

Homelabs vary greatly in terms of hardware and budget. The author is limited by available hardware, so the setup is rather modest — but deploying a highly available K3s cluster on it is a testament to how much software architecture matters, regardless of the underlying hardware.

| Name | Role | CPU | RAM | Storage | OS | Comment |
|------|------|-----|-----|---------|-----|---------|
| GMKtec NucBox G3 | K3s control plane, Home Assistant server, network services host, NFS server | Intel N100 | 16 GB | 1 TB NVMe | Proxmox VE | |
| Raspberry Pi 5 | K3s worker node, backup network | BCM2712 | 4 GB | 128 GB SSD | RPi OS Lite | |
| QNAP TS213P | Storage | AnnapurnaLabs Alpine AL212 1.7 GHz | 1 GB | 2 TB HDD | QNAP QTS | |
| Funbox 6 | ISP Router | — | — | — | — | Will be replaced soon |

## Deployment

Deployment guide will be available soon!
