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
  ];

  shellHook = ''
    alias k=kubectl
  '';
}