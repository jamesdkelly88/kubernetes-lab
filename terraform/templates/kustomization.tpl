apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: ${ name }
  namespace: flux-system
spec:
  interval: 10m0s
  path: ${ path }
  prune: true
  sourceRef:
    kind: GitRepository
    name: ${ repository }