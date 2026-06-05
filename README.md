# Homelab GitOps

Repository GitOps per il cluster k3s dell'homeserver.

## Stack attuale

### Kubernetes / GitOps
- k3s
- ArgoCD
- Uptime Kuma
- Headlamp

### Docker media stack esterno al cluster
- Jellyfin
- Jellyseerr
- Radarr
- Sonarr
- Prowlarr
- qBittorrent
- Homepage
- Portainer

## Accessi

I servizi sono esposti solo tramite rete privata Tailscale.

| Servizio | Porta |
|---|---:|
| ArgoCD | 31170 |
| Uptime Kuma | 31001 |
| Homelab Status | 31001 |
| Headlamp | 31002 |

## Struttura repository

```text
homelab-gitops/
├── apps/
│   ├── uptime-kuma/
│   └── headlamp/
├── argocd/
│   ├── applications/
│   └── root/
├── infra/
│   └── namespaces/
└── README.md
