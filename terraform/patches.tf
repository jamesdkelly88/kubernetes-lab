locals {
  patches = [
    # install disk
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/${local.context.install_disk}"
          image = "factory.talos.dev/metal-installer/${local.schematic_id}:v${local.context.talos_version}" # https://github.com/siderolabs/terraform-provider-talos/issues/272
        }
      }
    }),
    # single node
    yamlencode({
      cluster = {
        allowSchedulingOnControlPlanes = true
      }
    }),
    # metalLB
    yamlencode({
      cluster = {
        proxy = {
          extraArgs = {
            ipvs-strict-arp = "true"
          }
        }
      }
    }),
    # extensions
    yamlencode({
      machine = {
        install = {
          extensions = [
            {
              image = "ghcr.io/siderolabs/iscsi-tools:v0.2.0"
            },
            {
              image = "siderolabs/util-linux-tools:2.41.2"
            }
          ]
        }
      }
    }),
    # longhorn
    yamlencode({
      machine = {
        disks = [
          {
            device = "/dev/${local.context.volume_disk}"
            partitions = [
              {
                mountpoint = "/var/lib/longhorn"
                size       = 0 # Use entire disk
              }
            ]
          }
        ]
        kubelet = {
          extraMounts = [
            {
              destination = "/var/lib/longhorn"
              type        = "bind"
              source      = "/var/lib/longhorn"
              options = [
                "bind",
                "rshared",
                "rw"
              ]
            }
          ]
        }
      }
    }),
    # legacy version support
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