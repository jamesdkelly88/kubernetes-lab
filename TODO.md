# Kubernetes

- [ ] Configure kube-linter

# Terraform

- [x] read akeyless config secret
- [x] kind cluster
- [ ] talos cluster
- [x] write config secrets
- [x] update config role to allow delete (or suppress delete on secret resources)
- [x] read cluster akeyless secret
- [x] create kubernetes secret
- [x] deploy flux
- [x] deploy argocd
- [x] bootstrap flux
- [x] bootstrap argocd
- [x] try merging back into 1 folder with dynamic provider config
- [x] delete split folders and tidy up docs
- [x] cloud tfstate
- [x] multiple local clusters
- [ ] API call to update DuckDNS if not set to host IP
- [x] switch flux install to helm chart so repo write access not required

# Manifests

## cert-manager-duckdns

- [ ] include for Flux
- [x] Fix TXT record deletion script and publish custom image
- [x] try wildcard certificate at cluster level

## hello

- [x] find basic helm chart
- [x] deploy with flux
- [x] values file for flux
- [ ] overlay value file for flux
- [x] deploy with argocd
- [x] values file for argocd
- [x] overlay value file for argocd
- [x] same values files for both argocd and flux?
- [ ] include argocd in alpha and flux in beta to ensure no conflicts