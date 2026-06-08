# Homelab GitOps

Repository GitOps per il cluster k3s dell'homeserver.

L'obiettivo del progetto è costruire un ambiente homelab moderno, gestito in modo dichiarativo, usando:

- Kubernetes leggero con k3s
- GitOps con ArgoCD
- Infrastructure as Code con OpenTofu/Terraform
- Monitoring e dashboard operative
- Accesso sicuro tramite rete privata Tailscale

## Stack attuale

### Kubernetes / GitOps

- k3s
- ArgoCD
- App of Apps pattern
- Uptime Kuma
- Headlamp

### Infrastructure as Code

- OpenTofu
- Kubernetes provider
- Gestione dichiarativa dei namespace Kubernetes
- Import di risorse Kubernetes esistenti nello state OpenTofu

### Networking / Accesso

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
├── terraform/
│   └── bootstrap/
│       ├── providers.tf
│       └── main.tf
└── README.md
