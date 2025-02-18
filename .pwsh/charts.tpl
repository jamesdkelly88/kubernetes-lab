apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: charts
  namespace: argocd
spec:
  generators:
  - list:
      elements: []         
  template:
    metadata:
      name: "{{appName}}"
      annotations:
        argocd.argoproj.io/manifest-generate-paths: ".;.."
    spec:
      project: default
      sources:
      - repoURL: "{{repository}}"
        chart: "{{chart}}"
        targetRevision: "{{version}}"
        helm:
          valueFiles:
          - $self/apps/{{environment}}/{{appName}}/values.yaml
          ignoreMissingValueFiles: true
      - repoURL: https://github.com/jamesdkelly88/kubernetes-lab.git
        targetRevision: '{{ branch }}'
        ref: self
      destination:
        name: in-cluster
        namespace: "{{namespace}}"
      syncPolicy:
        automated:
          prune: true
          selfHeal: true
        syncOptions:
          - CreateNamespace=true