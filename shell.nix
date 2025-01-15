{ pkgs ? import <nixpkgs> {config.allowUnfree = true;} }:pkgs.mkShell {
  packages = with pkgs; [
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