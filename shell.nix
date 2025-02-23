{ pkgs ? import <nixpkgs> {config.allowUnfree = true;} }:pkgs.mkShell {
  packages = with pkgs; [
    argocd
    cmctl
    fluxcd
    gh
    go-task
    kind
    kube-linter
    kubectl
    kubernetes-helm
    powershell
    talosctl
    terraform
    tflint
  ];

  shellHook = ''
    alias k=kubectl
  '';
}
