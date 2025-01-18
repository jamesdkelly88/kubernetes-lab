# kubernetes-lab

Kubernetes homelab

## Structure

```

├── apps
│   ├── base
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
│   └── beta
├── terraform
│   ├── targets
│   │   ├── dev.tfvars
│   │   ├── local.tfvars
│   │   ├── production.tfvars
│   │   └── test.tfvars
│   └── <resources>.tf
├── .env
```

## .env file

```
TF_TOKEN_app_terraform_io=
TF_VAR_akeyless_id=
TF_VAR_akeyless_key=
```


## Usage

- Clusters are named after Greek letters (which may or may not be related to their contents) e.g Alpha - very experimental, Phi = production, Epsilon - empty (for manual setup stuff)
- Each cluster folder contains an ArgoCD and FluxCD definition, which points to the infrastructure and apps kustomizations.
- The infrastructure kustomization is deployed first, apps is deployed second
- The kustomization defines which infra and apps (and which environment overlays) are included in the cluster e.g Alpha uses the `local` overlays and DNS, Phi uses the `prod` ones.
- Local clusters use Kind, remote clusters use Talos. Clusters are deployed using Terraform, which bootstraps the selected CD operator with the initial resource. Everything else is then deployed and managed by CI/CD. This requires 2 stages so the kubeconfig of the cluster can be used by the Kubernetes Terraform provider.
- Secrets are stored remotely in Akeyless, including Git tokens, Kubeconfig and Talosconfig files. The only secrets known by the runner (user or pipeline) are the Akeyless credential and the Terraform cloud access token.

### Terraform
```sh
# open terraform directory
cd terraform
# select workspace
export TF_WORKSPACE=local
# initialise (with secrets)
env $(cat ../.env | xargs) terraform init
# plan (with secrets)
env $(cat ../.env | xargs) terraform plan -var 'cluster=alpha' -var 'host=local' -out=tfplan
# apply plan (with secrets)
env $(cat ../.env | xargs) terraform apply tfplan



# plan destroy (with secrets)
env $(cat ../.env | xargs) terraform plan -var 'cluster=alpha' -var 'host=local' -out=tfplan -destroy
```

### Kubectl

```sh
KUBECONFIG=~/.kube/local kubectl get nodes
```