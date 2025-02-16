$ErrorActionPreference = "Stop"

# Install-Module -Name powershell-yaml -Force -Scope CurrentUser
Import-Module -Name powershell-yaml

$repoRoot = ".."

$clustersFolder = Join-Path -Path $repoRoot -ChildPath "clusters"

$config =  (Get-Content -Path (Join-Path -Path $clustersFolder -ChildPath "clusters.yaml") -Raw) | ConvertFrom-Yaml -Ordered -AllDocuments

$types = @(
  @{
    name = "apps"
    folder = "apps"
  },
  @{
    name = "config"
    folder = "infrastructure"
  },
  @{
    name = "infrastructure"
    folder = "infrastructure"
  }
)

foreach($c in $config.clusters.keys)
{
  Write-Host "Updating cluster '$($c)'"
  $cluster = $config.clusters[$c]

  # resolve paths
  $paths = [PSCustomObject]@{
    apps = @()
    config = @()
    infrastructure = @()
  }

  foreach($t in $types)
  {
    foreach($v in $cluster."$($t.name)")
    {
      foreach($p in @("$($t.folder)/$c/$v","$($t.folder)/$($cluster.environment)/$v","$($t.folder)/base/$v"))
      {
        if(Test-Path (Join-Path -Path $repoRoot -ChildPath $p))
        {
          $paths."$($t.name)" += $p
          break
        }
      }
    }
  }

  # folder structure

  $folder = Join-Path -Path $clustersFolder -ChildPath $c
  if(-not (Test-path $folder))
  {
    Write-Host "Creating config folder"
    New-Item -ItemType Directory -Path $folder | Out-Null
  }

  foreach($sf in @("argocd","flux","flux/apps","flux/config","flux/infrastructure"))
  {
    $subfolder = Join-Path -Path $folder -ChildPath $sf
    if(-not (Test-path $subfolder))
    {
      Write-Host "Creating $sf folder"
      New-Item -ItemType Directory -Path $subfolder | Out-Null
    }
  }

  # argocd files



  # flux files

  ## flux.yaml

  [String]::Join("---`n",@(
    (
      [ordered]@{
        apiVersion = "source.toolkit.fluxcd.io/v1"
        kind = "GitRepository"
        metadata = [ordered]@{
          name = "flux-system"
          namespace = "flux-system"
        }
        spec = [ordered]@{
          interval = "1m0s"
          ref = @{
            branch = $cluster.branch
          }
          url = "https://github.com/jamesdkelly88/kubernetes-lab"
        }
      } | ConvertTo-Yaml
    ),
    (
      [ordered]@{
        apiVersion = "kustomize.toolkit.fluxcd.io/v1"
        kind = "Kustomization"
        metadata = [ordered]@{
          name = "flux-system"
          namespace = "flux-system"
        }
        spec = [ordered]@{
          interval = "10m0s"
          path = "./clusters/$c/flux"
          prune = $true
          sourceRef = [ordered]@{
            kind = "GitRepository"
            name = "flux-system"
          }
        }
      } | ConvertTo-Yaml
    )
  )) | Out-File -Path (Join-Path -Path $folder -ChildPath "flux.yaml")

  
  foreach($xx in @("apps","config","infrastructure"))
  {
    ## xx/kustomization.yaml
    [ordered]@{
      apiVersion = "kustomize.config.k8s.io/v1beta1"
      kind = "Kustomization"
      resources = $paths.$xx.foreach{ "../../../../$_/" }
    } | ConvertTo-Yaml |  Out-File -Path (Join-Path -Path $folder -ChildPath "flux/$xx/kustomization.yaml")

    ## xx.yaml
    $oxx = [ordered]@{
      apiVersion = "kustomize.toolkit.fluxcd.io/v1"
      kind = "Kustomization"
      metadata = [ordered]@{
        name = $xx
        namespace = "flux-system"
      }
      spec = [ordered]@{
        interval = "1h"
        retryInterval = "1m"
        timeout = "5m"
        sourceRef = [ordered]@{
          kind = "GitRepository"
          name = "flux-system"
        }
        path = "./clusters/$c/flux/$xx"
        prune = $true
        wait = $true
      }
    } 

    switch($xx){
      "apps" { $oxx.spec.Add("dependsOn",@{name = "infrastructure"}) }
      "infrastructure" { $oxx.spec.Add("dependsOn",@{name = "config"}) }
    }
    
    $oxx | ConvertTo-Yaml |  Out-File -Path (Join-Path -Path $folder -ChildPath "flux/$xx.yaml")
  }
  
}