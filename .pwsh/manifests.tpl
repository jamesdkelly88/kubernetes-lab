apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: manifests
  namespace: argocd
spec:
  generators:
  - list:
      elements: []
  template:
    metadata:
      name: '{{name}}'
      annotations:
        argocd.argoproj.io/sync-options: SkipDryRunOnMissingResource=true
    spec:
      project: default
      source:
        repoURL: https://github.com/jamesdkelly88/kubernetes-lab.git
        targetRevision: '{{ branch }}'
        path: 'apps/{{ environment }}/{{ name }}'
      destination:
        server: https://kubernetes.default.svc
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
        - ApplyOutOfSyncOnly=true
        - Replace={{replace}}
        - ServerSideApply={{serverside}}
