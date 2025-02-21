$ErrorActionPreference = "Stop"

# Install-Module -Name powershell-yaml -Force -Scope CurrentUser
Import-Module -Name powershell-yaml

$repoRoot = "$PSScriptRoot/.."

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

  foreach($sf in @("argocd","flux","flux/apps","flux/cluster","flux/config","flux/infrastructure"))
  {
    $subfolder = Join-Path -Path $folder -ChildPath $sf
    if(-not (Test-path $subfolder))
    {
      Write-Host "Creating $sf folder"
      New-Item -ItemType Directory -Path $subfolder | Out-Null
    }
  }

  # argocd files

  $charts = Get-Content -Path "$PSScriptRoot/charts.tpl" | ConvertFrom-Yaml -Ordered
  $manifests = Get-Content -Path "$PSScriptRoot/manifests.tpl" | ConvertFrom-Yaml -Ordered
  $infra_charts = Get-Content -Path "$PSScriptRoot/charts.tpl" | ConvertFrom-Yaml -Ordered
  $infra_charts.metadata.name = "infra-charts"
  $infra_charts.spec.template.spec.sources[0].helm.valueFiles[0] = '$self/infrastructure/{{environment}}/{{appName}}/values.yaml'
  $infra_manifests = Get-Content -Path "$PSScriptRoot/manifests.tpl" | ConvertFrom-Yaml -Ordered
  $infra_manifests.metadata.name = "infra-manifests"
  $infra_manifests.spec.template.spec.source.path = 'infrastructure/{{ environment }}/{{ name }}'

  foreach($a in $paths.apps)
  {
    $name = $a.split("/")[2]
    $environment = $a.split("/")[1]
    $gci = Get-ChildItem -path (Join-Path -Path $repoRoot -ChildPath "apps/base/$name")
    if($gci.name -contains "release.yaml")
    {
      # Chart
      $release = Get-Content (Join-Path -Path $repoRoot -ChildPath "apps/base/$name/release.yaml") | ConvertFrom-Yaml
      $repository = Get-Content (Join-Path -Path $repoRoot -ChildPath "apps/base/$name/repository.yaml") | ConvertFrom-Yaml

      $charts.spec.generators[0].list.elements += [ordered]@{
        appName = $name
        branch = $cluster.branch
        chart = $release.spec.chart.spec.chart
        environment = $environment
        namespace = $release.spec.chart.spec.sourceRef.namespace
        repository = $repository.spec.url
        version = $release.spec.chart.spec.version
      }
    }
    else 
    {
      # Manifest
      $manifests.spec.generators[0].list.elements += [ordered]@{
        name = $name
        environment = $environment
        branch = $cluster.branch
      }
    }
  }

  foreach($i in $paths.config + $paths.infrastructure)
  {
    $name = $i.split("/")[2]
    $environment = $i.split("/")[1]
    $gci = Get-ChildItem -path (Join-Path -Path $repoRoot -ChildPath "infrastructure/base/$name")
    if($gci.name -contains "release.yaml")
    {
      # Chart
      $release = Get-Content (Join-Path -Path $repoRoot -ChildPath "infrastructure/base/$name/release.yaml") | ConvertFrom-Yaml
      $repository = Get-Content (Join-Path -Path $repoRoot -ChildPath "infrastructure/base/$name/repository.yaml") | ConvertFrom-Yaml

      $infra_charts.spec.generators[0].list.elements += [ordered]@{
        appName = $name
        branch = $cluster.branch
        chart = $release.spec.chart.spec.chart
        environment = $environment
        namespace = $release.spec.chart.spec.sourceRef.namespace
        repository = $repository.spec.url
        version = $release.spec.chart.spec.version
      }
    }
    else 
    {
      # Manifest
      $infra_manifests.spec.generators[0].list.elements += [ordered]@{
        name = $name
        environment = $environment
        branch = $cluster.branch
      }
    }
  }

  $charts | ConvertTo-Yaml | Out-File -Path (Join-Path -Path $folder -ChildPath "argocd/charts-appset.yaml")
  $manifests | ConvertTo-Yaml | Out-File -Path (Join-Path -Path $folder -ChildPath "argocd/manifests-appset.yaml")
  $infra_charts | ConvertTo-Yaml | Out-File -Path (Join-Path -Path $folder -ChildPath "argocd/infra-charts-appset.yaml")
  $infra_manifests | ConvertTo-Yaml | Out-File -Path (Join-Path -Path $folder -ChildPath "argocd/infra-manifests-appset.yaml")


  # flux files

  ## cluster

  ### kustomization.yaml
  [ordered]@{
    apiVersion = "kustomize.config.k8s.io/v1beta1"
    kind = "Kustomization"
    namespace = "flux-system"
    resources = @(
      "apps.yaml",
      "config.yaml",
      "gitrepository.yaml",
      "infrastructure.yaml"
    )
  } | ConvertTo-Yaml |  Out-File -Path (Join-Path -Path $folder -ChildPath "flux/cluster/kustomization.yaml")

  ### gitrepository.yaml

  [ordered]@{
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind = "GitRepository"
    metadata = [ordered]@{
      name = "flux-system"
    }
    spec = [ordered]@{
      interval = "1m0s"
      ref = @{
        branch = $cluster.branch
      }
      url = "https://github.com/jamesdkelly88/kubernetes-lab"
    }
  } | ConvertTo-Yaml | Out-File -Path (Join-Path -Path $folder -ChildPath "flux/cluster/gitrepository.yaml")

  foreach($xx in @("apps","config","infrastructure"))
  {
    ## xx/kustomization.yaml
    [ordered]@{
      apiVersion = "kustomize.config.k8s.io/v1beta1"
      kind = "Kustomization"
      resources = $paths.$xx.foreach{ "../../../../$_/" }
    } | ConvertTo-Yaml |  Out-File -Path (Join-Path -Path $folder -ChildPath "flux/$xx/kustomization.yaml")

    ### xx.yaml
    $oxx = [ordered]@{
      apiVersion = "kustomize.toolkit.fluxcd.io/v1"
      kind = "Kustomization"
      metadata = [ordered]@{
        name = $xx
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
      "apps" { $oxx.spec.Add("dependsOn",@(@{name = "infrastructure"})) }
      "infrastructure" { $oxx.spec.Add("dependsOn",@(@{name = "config"})) }
    }
    
    $oxx | ConvertTo-Yaml |  Out-File -Path (Join-Path -Path $folder -ChildPath "flux/cluster/$xx.yaml")
  }
  
}