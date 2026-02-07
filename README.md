# Homelab
This repository contains the configuration for my homelab - small home server in my room. It consists of a few docker containers (crucial services like DNS, DHCP, VPN) and k3s cluster (apps, websites, etc.).

## Project goals and ideas
- everything is overkill but is stable and fun
- i try to use as lightweight and clean software as possible
- i prefer open source and free software ONLY
- i avoid cloud services
- security and code cleanliness is the most important thing
- i prefer to write 


## Hardware
Currently I have two machines:

### Main server
GMKtec NucBox G3

- CPU: Intel N100
- RAM: 16GB
- Storage: 1TB NVMe SSD
- OS: Proxmox VE (Debian based)

### Raspberry Pi 5 4GB
It has only 4GB of RAM because I bought it to test some rust network tools and haven't planned to use it for anything more advanced. Now i decided to use it as part of my homelab.

- CPU: Broadcom BCM2712
- RAM: 4GB
- Storage: 128GB SSD
- OS: Raspberry Pi OS Lite (Debian based)

## Software

