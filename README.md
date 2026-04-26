# kubernetes-lab

This is the code repository for the Kubernetes in my homelab. All clusters are deployed as single nodes running Talos Linux using Terraform and FluxCD.

## Structure (WIP)

```
├── .github
│   └── actions
├── .vscode
│   └── settings.json
├── apps
│   ├── helm-app
│   │   ├── base
│   │   ├── staging
│   │   └── production
│   └── manifest-app
│       ├── base
│       ├── staging
│       └── production
├── flux
│   ├── cluster1
│   │   └── kustomization.yaml
│   └── cluster2
│       └── kustomization.yaml
├── terraform
│   └── cluster
├── .env
├── .gitignore
├── LICENSE
├── README.md
├── renovate.json
├── shell.nix
└── Taskfile.yml
```

## Useful commands

TBC

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