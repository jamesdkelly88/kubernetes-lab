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
│   │   ├── apps
│   │   │   ├── charts-appset.yaml               # argocd applicationset selecting helm apps
│   │   │   ├── kustomization.yaml               # fluxcd kustomize selecting apps
│   │   │   └── manifests-appset.yaml            # argocd applicationset selecting manifest apps
│   │   ├── flux
│   │   │   ├── flux-system                      # auto generated
│   │   │   │   ├── gotk-components.yaml
│   │   │   │   ├── gotk-sync.yaml
│   │   │   │   └── kustomization.yaml
│   │   │   ├── apps.yaml                        # flux definition for apps/kustomization.yaml
│   │   │   └── infrastructure.yaml              # flux definition for infrastructure/kustomization.yaml
│   │   ├── infrastructure
│   │   │   ├── charts-appset.yaml               # argocd applicationset selecting helm infrastructure components
│   │   │   ├── kustomization.yaml               # fluxcd kustomize selecting infrastructure components
│   │   │   └── manifests-appset.yaml            # argocd applicationset selecting manifest infrastructure components
│   │   └── argocd.yaml                          # argocd application defining applicationsets directory to use
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
TF_TOKEN_app_terraform_io=
TF_VAR_akeyless_id=
TF_VAR_akeyless_key=
```

## Usage

- Clusters are named after Greek letters (which may or may not be related to their contents) e.g Alpha - very experimental, Phi = production, Epsilon - empty (for manual setup stuff)
- Each cluster folder contains ArgoCD and FluxCD definitions, which points to the infrastructure and apps to be deployed.
- The infrastructure kustomization is deployed first, apps is deployed second (Flux only currently)
- The kustomization defines which infra and apps (and which environment overlays) are included in the cluster e.g Alpha uses the `local` overlays and DNS, Phi uses the `prod` ones.
- Local clusters use Kind, remote clusters use Talos. Clusters are deployed using Terraform, which bootstraps the selected CD operator with the initial resource. Everything else is then deployed and managed by CI/CD. This requires 2 stages so the kubeconfig of the cluster can be used by the Kubernetes Terraform provider.
- Secrets are stored remotely in Akeyless, including Git tokens, Kubeconfig and Talosconfig files. The only secrets known by the runner (user or pipeline) are the setup Akeyless credential and the Terraform cloud access token.

### Akeyless

TBC

## DuckDNS

TBC

### Kubectl

```sh
KUBECONFIG=~/.kube/local1 kubectl get nodes
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
# initialise (with secrets)
env $(cat ../.env | xargs) terraform init
# plan (with secrets)
env $(cat ../.env | xargs) terraform plan -var 'cluster=alpha' -out=tfplan
# apply plan (with secrets)
env $(cat ../.env | xargs) terraform apply tfplan


# plan destroy (with secrets)
env $(cat ../.env | xargs) terraform plan -var 'cluster=alpha' -out=tfplan -destroy
```

