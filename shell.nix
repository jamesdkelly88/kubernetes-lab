{ pkgs ? import <nixpkgs> {config.allowUnfree = true;} }:pkgs.mkShell {
  packages = with pkgs; [
    bws
    gh
    go-task
    jq
    kubectl
    talosctl
    terraform
    tflint
  ];

  shellHook = ''
    alias k=kubectl
    alias kaf="kubectl apply -f"
    alias kak="kubectl apply -k"

    export $(cat .env | xargs)
  '';
}
