{ pkgs ? import <nixpkgs> {config.allowUnfree = true;} }:pkgs.mkShell {
  packages = with pkgs; [
    argocd
    fluxcd
    gh
    go-task
    kind
    kubectl
    talosctl
    terraform
    tflint
  ];

  shellHook = ''
    alias k=kubectl
  '';
}