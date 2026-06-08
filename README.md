# Homelab GitOps

Repository GitOps per il cluster k3s dell'homeserver.

L'obiettivo del progetto è costruire un ambiente homelab moderno, gestito in modo dichiarativo, usando:

- Kubernetes leggero con k3s
- GitOps con ArgoCD
- Infrastructure as Code con OpenTofu/Terraform
- Observability con Prometheus e Grafana
- Gestione certificati TLS con cert-manager
- Pipeline di validazione con GitHub Actions
- Accesso sicuro tramite rete privata Tailscale

## Stack attuale

### Kubernetes / GitOps

- k3s
- ArgoCD
- App of Apps pattern
- Uptime Kuma
- Headlamp
- Whoami
- Grafana Ingress gestito via ArgoCD

### Infrastructure as Code

- OpenTofu
- Kubernetes provider
- Helm provider
- Gestione dichiarativa dei namespace Kubernetes
- Installazione di componenti platform tramite Helm chart
- Import di risorse Kubernetes esistenti nello state OpenTofu

### Observability

- kube-prometheus-stack
- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- node-exporter
- Prometheus Operator

### TLS / Certificate Management

- cert-manager
- ClusterIssuer self-signed
- Certificati TLS generati automaticamente per gli Ingress

### CI/CD

- GitHub Actions
- OpenTofu Validate
- Kubernetes Manifests Validate

## Accessi

I servizi sono esposti solo tramite rete privata Tailscale.

| Servizio | URL / Porta |
|---|---|
| ArgoCD | `https://100.122.123.125:31170` |
| Uptime Kuma | `http://100.122.123.125:31001` |
| Homelab Status | `http://100.122.123.125:31001` |
| Headlamp | `http://100.122.123.125:31002` |
| Grafana | `http://100.122.123.125:31030` |
| Prometheus | `http://100.122.123.125:31090` |

## Struttura repository

```text
homelab-gitops/
├── apps/
│   ├── grafana/
│   ├── headlamp/
│   ├── uptime-kuma/
│   └── whoami/
├── argocd/
│   ├── applications/
│   └── root/
├── terraform/
│   └── bootstrap/
│       ├── cert-manager-issuer.tf
│       ├── cert-manager.tf
│       ├── main.tf
│       ├── monitoring.tf
│       └── providers.tf
├── .github/
│   └── workflows/
│       ├── kubernetes-validate.yml
│       └── opentofu-validate.yml
├── .gitignore
└── README.md
```

## GitOps

ArgoCD è usato per mantenere sincronizzate le applicazioni Kubernetes con lo stato dichiarato nel repository Git.

Il repository utilizza il pattern App of Apps:

- una root application gestisce le application figlie
- ogni applicazione viene definita come manifest Kubernetes
- le modifiche vengono applicate tramite commit Git e sincronizzazione ArgoCD

Applicazioni attualmente gestite da ArgoCD:

- Uptime Kuma
- Headlamp
- Whoami
- Grafana Ingress

Verificare le applicazioni ArgoCD:

```bash
kubectl get applications -n argocd
```

Forzare un hard refresh della root app:

```bash
kubectl annotate application homelab-apps -n argocd argocd.argoproj.io/refresh=hard --overwrite
```

## Infrastructure as Code

OpenTofu viene usato per gestire il bootstrap infrastrutturale del cluster k3s.

La configurazione si trova in:

```text
terraform/bootstrap/
```

Risorse attualmente gestite tramite OpenTofu:

- namespace `homelab`
- namespace `monitoring`
- namespace `ingress`
- namespace `cert-manager`
- installazione `cert-manager` tramite Helm provider
- `ClusterIssuer` self-signed
- installazione `kube-prometheus-stack` tramite Helm provider

I namespace vengono etichettati con label descrittive, ad esempio:

```text
app.kubernetes.io/managed-by=opentofu
homelab.lorenzo.io/purpose=observability
```

Questo permette di distinguere chiaramente le risorse create o gestite tramite Infrastructure as Code.

### Comandi OpenTofu

Entrare nella cartella bootstrap:

```bash
cd terraform/bootstrap
```

Inizializzare OpenTofu:

```bash
tofu init
```

Formattare i file HCL:

```bash
tofu fmt
```

Validare la configurazione:

```bash
tofu validate
```

Visualizzare il piano di modifica:

```bash
tofu plan
```

Applicare le modifiche:

```bash
tofu apply
```

Visualizzare le risorse gestite nello state:

```bash
tofu state list
```

## TLS e cert-manager

Il cluster usa `cert-manager` per la gestione automatica dei certificati TLS sugli Ingress Kubernetes.

`cert-manager` è installato tramite OpenTofu usando Helm provider, mentre il `ClusterIssuer` viene gestito come risorsa Kubernetes dichiarativa tramite OpenTofu.

Attualmente è configurato un `ClusterIssuer` self-signed:

```text
selfsigned-cluster-issuer
```

Questo issuer viene usato per generare certificati TLS interni al cluster.

Esempio di flusso:

```text
Ingress Kubernetes
→ annotation cert-manager.io/cluster-issuer
→ cert-manager
→ ClusterIssuer
→ Certificate
→ Secret TLS
→ Traefik
→ HTTPS verso il servizio
```

Esempi attuali:

```text
https://kuma.homelab.local:30443
https://grafana.homelab.local:30443
```

Il certificato è self-signed, quindi il browser può mostrare un warning di sicurezza. Questo è normale in ambiente homelab.

Verificare i certificati:

```bash
kubectl get certificate -A
```

Verificare i Secret TLS:

```bash
kubectl get secret -A | grep tls
```

## Observability

Il cluster include uno stack di observability basato su `kube-prometheus-stack`, installato tramite OpenTofu con Helm provider.

Componenti installati:

- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- node-exporter
- Prometheus Operator

La configurazione OpenTofu si trova in:

```text
terraform/bootstrap/monitoring.tf
```

Il namespace dedicato è:

```text
monitoring
```

### Accesso Grafana

Grafana è esposto sia tramite Ingress TLS sia tramite NodePort per accesso pratico da rete privata Tailscale.

Accesso pratico:

```text
http://100.122.123.125:31030
```

Credenziali iniziali:

```text
username: admin
password: admin
```

Accesso production-like tramite Ingress/TLS:

```text
https://grafana.homelab.local:30443
```

Il certificato TLS è generato automaticamente da cert-manager tramite il `ClusterIssuer` self-signed.

### Accesso Prometheus

Prometheus è esposto tramite NodePort:

```text
http://100.122.123.125:31090
```

Query PromQL utili per test:

```promql
up
```

```promql
kube_pod_info
```

```promql
container_memory_usage_bytes
```

### Verifiche monitoring

Verificare i pod:

```bash
kubectl get pods -n monitoring
```

Verificare i servizi:

```bash
kubectl get svc -n monitoring
```

Verificare Ingress Grafana:

```bash
kubectl get ingress -n monitoring
```

Verificare certificato TLS Grafana:

```bash
kubectl get certificate -n monitoring
kubectl get secret grafana-tls -n monitoring
```

## CI/CD

Il repository include workflow GitHub Actions per validare automaticamente le modifiche.

Workflow attivi:

- OpenTofu Validate
- Kubernetes Manifests Validate

### OpenTofu Validate

Valida la configurazione Infrastructure as Code sotto:

```text
terraform/
```

Esegue:

```text
tofu fmt -check
tofu init -backend=false
tofu validate
```

### Kubernetes Manifests Validate

Valida i manifest Kubernetes sotto:

```text
apps/
argocd/
```

Il flusso attuale è:

```text
Git push
→ GitHub Actions validation
→ ArgoCD sync
→ k3s cluster
```

## Separazione responsabilità

Il progetto separa chiaramente le responsabilità tra OpenTofu e ArgoCD.

OpenTofu gestisce il bootstrap e i componenti platform:

- namespace Kubernetes
- cert-manager
- ClusterIssuer
- kube-prometheus-stack
- risorse infrastrutturali di base

ArgoCD gestisce le applicazioni:

- Deployment
- Service
- Ingress applicativi
- configurazione GitOps delle app

Questa separazione evita conflitti tra tool diversi e mantiene chiaro quale sistema gestisce ogni risorsa.

## Comandi utili

Verificare i namespace:

```bash
kubectl get ns
```

Verificare le label dei namespace gestiti da OpenTofu:

```bash
kubectl get ns homelab monitoring ingress cert-manager --show-labels
```

Verificare le applicazioni ArgoCD:

```bash
kubectl get applications -n argocd
```

Verificare i servizi esposti:

```bash
kubectl get svc -A
```

Verificare gli Ingress:

```bash
kubectl get ingress -A
```

Verificare i certificati:

```bash
kubectl get certificate -A
```

Verificare lo stato OpenTofu:

```bash
cd terraform/bootstrap
tofu plan
```

## Roadmap

Prossimi step possibili:

- gestire credenziali tramite Secret Kubernetes o External Secrets
- creare dashboard Grafana personalizzata Homelab Overview
- configurare alert base su Prometheus / Alertmanager
- aggiungere monitoring di Docker media stack esterno a k3s
- migliorare accessi tramite DNS interno o reverse proxy più comodo
- introdurre remote state per OpenTofu
- aggiungere backup dei PVC
- introdurre policy/security scanning dei manifest

## Stato attuale del progetto

Componenti principali attualmente presenti:

- k3s
- ArgoCD
- App of Apps pattern
- OpenTofu / Terraform-style IaC
- cert-manager
- ClusterIssuer self-signed
- TLS su Ingress
- Uptime Kuma
- Headlamp
- Whoami
- Prometheus
- Grafana
- Alertmanager
- kube-state-metrics
- node-exporter
- GitHub Actions validation pipeline

## Note

Questo homelab è pensato come ambiente personale di studio e sperimentazione per competenze DevOps, Platform Engineering, Kubernetes, GitOps, Observability e Infrastructure as Code.
