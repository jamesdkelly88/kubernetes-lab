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