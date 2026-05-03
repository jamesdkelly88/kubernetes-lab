apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: ${ name }
  namespace: ${ namespace }
spec:
  interval: 1m0s
  ref:
    branch: ${ branch }
  url: ${ url }