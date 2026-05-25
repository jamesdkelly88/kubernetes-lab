#Requires -module powershell-yaml
$InformationPreference = "Continue"
$ErrorActionPreference = "Stop"

$repoRoot = "$PSScriptRoot/../.."

$config = Get-Content "${repoRoot}/clusters.yaml" | ConvertFrom-Yaml

foreach($c in $config.clusters)
{
  Write-Information "Building cluster $($c.name)"

  # Gateway definition
  $templateDir = Join-Path -Path $repoRoot -ChildPath "template"
  $gatewayDir = Join-Path -Path $templateDir -ChildPath "gateway",$c.name
  New-Item -ItemType Directory $gatewayDir -Force | Out-Null

  $listeners = @()
  $zone = $config.zones."$($c.dns)"

  foreach($p in $c.ports)
  {
    $port = $config.ports.$p

    $l = [ordered]@{
      name = $port.name
      port = $p
      protocol = $port.protocol
      allowedRoutes = @{
        namespaces = @{
          from = "All"
        }
      }
    }
    if($port.hostname)
    {
      $l.add("hostname", "*.${zone}")
    }
    if($port.tls)
    {
      $l.add("tls",@{
        certificateRefs = @(
          [ordered]@{
            kind = "Secret"
            group = ""
            name = "duckdns-cert"
          }
        )
      })
    }

    $p = [ordered]@{
      op = "add"
      path = "/spec/listeners/-"
      value = $l
    }

    $listeners += $p
  }
  $listeners | ConvertTo-Yaml | Out-File -NoNewLine -FilePath (Join-Path -Path $gatewayDir -ChildPath "listeners-patch.yaml")
  
  @(
    [ordered]@{
      op = "replace"
      path = "/spec/data/0/remoteRef/key"
      value = "tls/$($zone.split(".")[0])/cert"
    },
    [ordered]@{
      op = "replace"
      path = "/spec/data/1/remoteRef/key"
      value = "tls/$($zone.split(".")[0])/key"
    }
  ) | ConvertTo-Yaml | Out-File -NoNewLine -FilePath (Join-Path -Path $gatewayDir -ChildPath "certificate-patch.yaml")

  $k = [ordered]@{
    apiVersion = "kustomize.config.k8s.io/v1beta1"
    kind = "Kustomization"
    namespace = "nginx-gateway"
    resources = @("../base")
    patches = @(
      [ordered]@{
        path = "certificate-patch.yaml"
        target = [ordered]@{
          group = "external-secrets.io"
          version = "v1"
          kind = "ExternalSecret"
          name = "duckdns-cert"
        }
      },
      [ordered]@{
        path = "listeners-patch.yaml"
        target = [ordered]@{
          group = "gateway.networking.k8s.io"
          version = "v1"
          kind = "Gateway"
          name = "gateway"
        }
      }
    )
  } 

  $k | ConvertTo-Yaml | Out-File -NoNewLine -FilePath (Join-Path -Path $gatewayDir -ChildPath "kustomization.yaml")

  # Overlay definition
  $overlayDir = Join-Path -Path $repoRoot -ChildPath "overlay"
  $gwOverlayDir = Join-Path -Path $overlayDir -ChildPath "gateway"
  New-Item -ItemType Directory -Path $gwOverlayDir -Force | Out-Null

  [ordered]@{
    apiVersion = "kustomize.toolkit.fluxcd.io/v1"
    kind = "Kustomization"
    metadata = [ordered]@{
      name = "gateway"
      namespace = "flux-system"
    }
    spec = [ordered]@{
      interval = "1h"
      retryInterval = "1m"
      timeout = "5m"
      sourceRef = [ordered]@{
        kind = "GitRepository"
        name = "github"
      }
      path = "./template/gateway/$($c.name)"
      prune = $true
      wait = $true
      dependsOn = @(
        @{
          name = "nginx-gateway-fabric"
        }
      )
    }
  } | ConvertTo-Yaml | Out-File -NoNewLine -FilePath (Join-Path -Path $gwOverlayDir -ChildPath "$($c.name).yaml")

  # Kustomization
  $clusterDir = Join-Path -Path $repoRoot -ChildPath "cluster",$c.name
  New-Item -ItemType Directory -Path $clusterDir -Force | Out-Null

  $ck = [ordered]@{
    apiVersion = "kustomize.config.k8s.io/v1beta1"
    kind = "Kustomization"
    resources = @()
  }

  $services = ($c.apps + $config.services.core) | Sort-Object

  if("*" -in $services)
  {
    $services = Get-ChildItem -Path $templateDir -Directory | Select-Object -ExpandProperty Name | Sort-Object
  }

  foreach($s in $services)
  {
    # Check for cluster overlay
    if(Test-Path (Join-Path -Path $templateDir -ChildPath $s,$c.name,"kustomization.yaml"))
    {
      $overlay = "${s}/$($c.name).yaml"
    }
    # Check for environment overlay
    elseif(Test-Path (Join-Path -Path $templateDir -ChildPath $s,$c.dns,"kustomization.yaml"))
    {
      $overlay = "${s}/$($c.dns).yaml"
    }
    # Use base
    else
    {
      $overlay = "${s}.yaml"
    }
    $ck.resources += "../../overlay/${overlay}"
  }

  $ck | ConvertTo-Yaml | Out-File -NoNewLine -FilePath (Join-Path -Path $clusterDir -ChildPath "kustomization.yaml")

}