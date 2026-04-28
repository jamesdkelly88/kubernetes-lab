{ pkgs ? import <nixpkgs> { config.allowUnfree = true; } }:

let
  unstable = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    config.allowUnfree = true;
  };
in

pkgs.mkShell {
  packages = with pkgs; [
    bws
    gh
    go-task
    jq
    kubectl
    terraform
    tflint
  ] ++ [
    unstable.talosctl
  ];

  shellHook = ''
    alias k=kubectl
    alias kaf="kubectl apply -f"
    alias kak="kubectl apply -k"

    export $(cat .env | xargs)
  '';
}