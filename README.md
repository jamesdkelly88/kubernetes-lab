# kubernetes-lab

- [kubernetes-lab](#kubernetes-lab)
  - [Logical flow](#logical-flow)
  - [Structure](#structure)
  - [To use terraform](#to-use-terraform)
  - [To use flux cli](#to-use-flux-cli)
  - [To use kubectl](#to-use-kubectl)
  - [To use talosctl](#to-use-talosctl)
  - [To use helm cli](#to-use-helm-cli)
    - [Upgrading](#upgrading)
  - [Useful commands](#useful-commands)
  - [Hints and Tips](#hints-and-tips)


This is the code repository for the Kubernetes in my homelab. All clusters are deployed as single nodes running Talos Linux using Terraform and FluxCD.

## Logical flow

- Terraform installs and configures Talos
- Terraform creates API key secret for `external-secrets`
- Terraform installs Flux using Helm chart
- Terraform configures repository for Flux
- Terraform configures Flux to target `cluster/name`
- `cluster/name/kustomization.yaml` contains a list of `.yaml` files in `overlay`
- Each `.yaml` file in `overlay` is a Flux Kustomization targeting a folder in `template`
- Each folder in `template` contains a Kubernetes Kustomization and resource manifests
- Terraform is used to refresh secrets, change branch/cluster target and upgrade Flux

<!-- TODO: can the Flux helm chart be included in the repo for self-updating? -->

## Structure

```
├── .github
│   └── actions
|
├── .vscode
│   └── settings.json
|
├── cluster
│   ├── cluster1
│   │   └── kustomization.yaml       # list of flux kustomizations in overlay folder
│   └── cluster2
│       └── kustomization.yaml       
|
├── overlay
│   ├── core-app.yaml                # flux kustomize for app with no environment overlays
│   ├── helm-app
│   │   ├── dev.yaml                 # flux kustomize for app with environment-specific overlays
│   │   ├── staging.yaml
│   │   └── production.yaml
│   └── manifest-app
│       ├── dev
│       ├── staging
│       └── production
|
├── template
│   ├── helm-app
|   |   ├── base
|   │   |   ├── kustomization.yaml   # kubernetes manifests for app
|   |   |   └── resource(s).yaml
|   |   ├── dev
|   │   |   └── kustomization.yaml   # dev environment overlay for app
|   |   ├── staging
|   │   |   └── kustomization.yaml   # staging environment overlay for app
|   |   └── production
|   │       └── kustomization.yaml   # production environment overlay for app
│   ├── manifest-app
|   |   └── base
|   │       ├── kustomization.yaml
|   |       └── resource(s).yaml
│   └── kustomizeconfig.yaml         # config patch to allow Helm values customisation
|
├── terraform
|   ├── data.tf                      
|   ├── flux.tf                      # flux helm deployment and repository bootstrap
|   ├── locals.tf                    
|   ├── outputs.tf
|   ├── patches.tf                   # talos machine config patches
|   ├── providers.tf
|   ├── secrets.tf                   # upload talosconfig and kubeconfig, create token secret for external-secrets to access BWS
|   ├── talos.tf                     # talos cluster config generation and bootstrap
|   └── talosconfig.tpl              # talosconfig yaml template
|
├── .env
├── .gitignore
├── LICENSE
├── README.md
├── renovate.json
├── shell.nix
└── Taskfile.yml
```

## To use terraform
```sh
export TF_WORKSPACE=xxxx
export TF_TOKEN_app_terraform_io=<secret>
export BW_ORGANIZATION_ID=<guid>
export BW_ACCESS_TOKEN=<secret>
cd terraform
terraform init
terraform plan
terraform apply
```

## To use flux cli
```sh
task kubeconfig HOST=xxxx
export KUBECONFIG=kubeconfig/xxxx
flux get all
flux reconcile kustomization app
```

## To use kubectl

```sh
task kubeconfig HOST=xxxx
export KUBECONFIG=kubeconfig/xxxx
kubectl get nodes
```

## To use talosctl

```sh
task talosconfig HOST=xxxx
export TALOSCONFIG=talosconfig/xxxx
talosctl version
```

## To use helm cli
```sh
export KUBECONFIG=kubeconfig/host
helm repo add flux https://fluxcd-community.github.io/helm-charts
helm install flux flux/flux2 --version 2.18.3  --namespace flux-system --create-namespace
helm list -A
```

The example above performs a manual install of Flux if the terraform fails. This can then be imported into the state with:
```sh
terraform import helm_release.flux flux-system/flux
```


### Upgrading

- Check the [compatibility matrix](https://docs.siderolabs.com/talos/latest/getting-started/support-matrix)
- Upgrade Talos - [available versions](https://github.com/siderolabs/talos/releases)
```sh
talosctl upgrade --preserve --image ghcr.io/siderolabs/installer:v1.x.y"
```
- Upgrade Kubernetes - [available versions](https://github.com/siderolabs/kubelet/releases) **you should always go to the latest minor version before a major version upgrade**
```sh
talosctl upgrade-k8s --to 1.x.y
```

## Useful commands

- Get ports that are being listened to by deployment: `kubectl -n <namespace> exec deploy/<name> -- ss -tlnp`
- Test MetalLB L2 advertisement: `sudo arping -I <local-interface> <vip>`

## Hints and Tips

- To reattach a Longhorn PV after it is released:
  - Update the PVC definition to include the `volumeName` in the spec
  - Edit the PV definition and remove `metadata/uid` and `spec/claimRef` - Headlamp has a good editor for this