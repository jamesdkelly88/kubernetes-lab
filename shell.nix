{ pkgs ? import <nixpkgs> {config.allowUnfree = true;} }:pkgs.mkShell {
  packages = with pkgs; [
    argocd
    fluxcd
    gh
    go-task
    kind
    kube-linter
    kubectl
    kubernetes-helm
    talosctl
    terraform
    tflint
  ];

  shellHook = ''
    alias k=kubectl
  '';
}
