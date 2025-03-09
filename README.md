# kubernetes-lab

Kubernetes homelab

## Structure

```

├── apps
│   ├── base
│   │   ├── helm-app
│   │   │   ├── kustomization.yaml               # kustomization used by fluxcd
│   │   │   ├── kustomizeconfig.yaml             # allow kustomize to set Helm values from file
│   │   │   ├── namespace.yaml                   # add labels to created namespace (needs a solution for ArgoCD)
│   │   │   ├── release.yaml                     # flux HelmRelease
│   │   │   ├── repository.yaml                  # flux HelmRepository
│   │   │   └── values.yaml                      # chart values file (only part also used by argocd)
│   │   └── manifest-app
│   │       ├── kustomization.yaml               # kustomization used by argocd/fluxcd
│   │       ├── namespace.yaml                   # add labels to created namespace
│   │       └── other manifests...               # resources defined in manifests
│   ├── dev
│   ├── local  
│   ├── production 
│   └── test
├── infrastructure
│   ├── base
│   ├── dev
│   ├── local  
│   ├── production 
│   └── test
├── clusters
│   ├── alpha
│   │   ├── argocd.yaml                          # argocd application defining applicationsets directory to use
│   │   ├── argocd
│   │   │   ├── charts-appset.yaml               # argocd applicationset selecting helm apps
│   │   │   ├── infra-charts-appset.yaml         # argocd applicationset selecting helm infrastructure components
│   │   │   ├── manifests-appset.yaml            # argocd applicationset selecting manifest apps
│   │   │   └── infra-manifests-appset.yaml      # argocd applicationset selecting manifest infrastructure components
│   │   └── flux
│   │       ├── apps
│   │       │   └── kustomization.yaml           # list of apps folders to apply
│   │       ├── cluster
│   │       │   ├── apps.yaml                    # fluxcd kustomize selecting apps (third phase)
│   │       │   ├── config.yaml                  # fluxcd kustomize selecting config (first phase)
│   │       │   ├── gitrepository.yaml           # gitrepository definition for fluxcd to use this repository
│   │       │   ├── infrastructure.yaml          # fluxcd kustomize selecting infrastructure (second phase)
│   │       │   └── kustomization.yaml           # kustomize defining fluxcd resources
│   │       ├── config
│   │       │   └── kustomization.yaml           # list of infrastructure folders to apply first
│   │       └── infrastructure
│   │           └── kustomization.yaml           # list of infrastructure folders to apply second
│   └── beta
├── terraform
│   ├── locals.tf                                # host and cluster configuration
│   └── <resources>.tf
├── .env
├── .gitignore
├── LICNSE
├── README.md
├── renovate.json
├── shell.nix
└── Taskfile.yml
```

## .env file

```
AKEYLESS_ID=
AKEYLESS_KEY=
TERRAFORM_TOKEN=
```

## Usage

- Clusters are named after Greek letters (which may or may not be related to their contents) e.g Alpha - very experimental, Phi = production, Epsilon - empty (for manual setup stuff)
- Each cluster folder contains ArgoCD and FluxCD definitions, which points to the infrastructure and apps to be deployed.
- The infrastructure kustomization is deployed first, apps is deployed second (Flux only currently)
- The kustomization defines which infra and apps (and which environment overlays) are included in the cluster e.g Alpha uses the `local` overlays and DNS, Phi uses the `prod` ones.
- Local clusters use Kind, remote clusters use Talos. Clusters are deployed using Terraform, which bootstraps the selected CD operator with the initial resource. Everything else is then deployed and managed by CI/CD. This requires 2 stages so the kubeconfig of the cluster can be used by the Kubernetes Terraform provider.
- Secrets are stored remotely in Akeyless, including Git tokens, Kubeconfig and Talosconfig files. The only secrets known by the runner (user or pipeline) are the setup Akeyless credential and the Terraform cloud access token.
- Ingress should **not** specify an ingress class, as each ingress controller should define itself as the default. This allows for trying out different controllers without having to patch the ingress definitions.

### Akeyless

TBC

### Cert-Manager

### Force-renew a certificate

`cmctl renew <cert-name> -n <cert-namespace>`

### DuckDNS

TBC

### Kubectl

```sh
KUBECONFIG=~/.kube/local1 kubectl get nodes
```

```powershell
$env:KUBECONFIG="$env:USERPROFILE/.kube/local1"
kubectl get nodes
```

#### Port forwarding

```sh
KUBECONFIG=~/.kube/local1 kubectl port-forward deployment/[name] -n [namespace] [localPort]:[containerPort]
```

### Terraform

#### With Task

`task build CLUSTER=alpha` and `task destroy CLUSTER=alpha`

#### Manually

```sh
# open terraform directory
cd terraform
# select workspace
export TF_WORKSPACE=alpha
export TF_TOKEN_app_terraform_io=<token>
# initialise (with secrets)
terraform init
# plan (with secrets)
terraform plan -var 'cluster=alpha' -var 'akeyless_id=<secret>' -var 'akeyless_key=<secret>' -out=tfplan
# apply plan (with secrets)
terraform apply tfplan


# plan destroy (with secrets)
env $(cat ../.env | xargs) terraform plan -var 'cluster=alpha' -out=tfplan -destroy
```

## Adding to clusters

### ArgoCD

- helm charts only require a values file - the chart definition is handled by applicationset
- update spec.generators.list with new definiton
  - add application manifests to `manifests-appset.yaml`
  - add application charts to `charts-appset.yaml`
  - add infrastructure manifests to `infra-manifests-appset.yaml`
  - add infrastructure charts to `infra-charts-appset.yaml`

### FluxCD

- helm charts must be defined as flux resources
- update kustomization.yaml with relative path to manifests
  - add applications to `flux/apps/kustomization.yaml`
  - add infrastructure to `flux/infrastructure/kustomization.yaml`
  - add config dependencies to `flux/config/kustomization.yaml`

### Manually

Minimum install for a functional cluster:
- infrastructure/external-secrets
- infrastructure/external-secrets-store
- a duckdns certificate source
- an ingress controller

#### Helm

```
export KUBECONFIG=~/.kube/<host>
helm repo add <repo name> <repo url>
helm repo update
helm search repo
helm install -n <namespace> -f values.yaml --create-namespace <release name> <repo name>/<chart name>
```

Removing:

```
helm uninstall <release name>
helm repo remove <repo name>
```

#### Manifests

```
export KUBECONFIG=~/.kube/<host>
kubectl apply -k <folder>
```

Removing:

```
kubectl delete -k <folder>
```
