# Docker

In this repository Docker is responsible only for running most crucial services (like networking)or the ones that I want to purposefuly isolate from my Kubernetes cluster (like services on external VPS).

For simple management Portainer is advised to use. It is deployed under [./net](./net/compose.yaml)

All `compose.yaml` files come with their own `stack.env` files that defined environment variables. The defualt volumes path is set to `/opt/docker/<service_name>`, which is believed by the repo author to be the most convenient and universal location.
