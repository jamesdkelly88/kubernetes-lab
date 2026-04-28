locals {
  patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/${local.context.install_disk}"
          image = "ghcr.io/siderolabs/installer:v${local.context.talos_version}" # https://github.com/siderolabs/terraform-provider-talos/issues/272
        }
      }
    }),
    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = true
      }
    }),
    yamlencode({
      machine = {
        install = {
          grubUseUKICmdline = {
            "$patch" = "delete"
          }
        }
      }
    })
  ]
}