$ErrorActionPreference = "Stop"

# Install-Module -Name powershell-yaml -Force -Scope CurrentUser
# Install-Module -Name Hcl2PS -Scope CurrentUser

Import-Module -Name powershell-yaml
Import-Module -Name Hcl2PS

$skipClusters = @("gamma")

$links = Get-Content -Raw -Path "$PSScriptRoot/links.json" | ConvertFrom-Json

$repoRoot = "$PSScriptRoot/.."

$clustersFolder = Join-Path -Path $repoRoot -ChildPath "clusters"
$config =  (Get-Content -Path (Join-Path -Path $clustersFolder -ChildPath "clusters.yaml") -Raw) | ConvertFrom-Yaml -Ordered -AllDocuments

$terraformFolder = Join-Path -Path $repoRoot -ChildPath "terraform"
$locals = (Get-Content -Path (Join-Path -Path $terraformFolder -ChildPath "locals.tf") -Raw) | ConvertFrom-Hcl

foreach($clusterName in $config.clusters.Keys)
{
  if($clusterName -in $skipClusters) { continue }
  Write-Host "Cluster: $($clusterName)"

  $clusterConfig = $config.clusters[$clusterName]
  $clusterTf = $locals.locals.clusters.$clusterName
  $clusterHost = $locals.locals.hosts."$($clusterTf.host)"

  $environment = $clusterHost.secret

  $greek = switch($clusterName)
  {
    "alpha" {"α"}
    "beta" {"β"}
    "gamma" {"γ"}
    default { Write-Error "Unknown greek letter $_"}
  }

  $dns = switch($environment){
    "local" { ".jklocal.duckdns.org" }
    default { Write-Error "Unknown DNS environment: $environment"}
  }
  $webPort = $clusterhost.ports.psobject.properties.where{ $_.value -eq 443 }.name
  if($webPort -eq "443")
  {
    $webPort = ""
  }
  else
  {
    $webPort = ":$($webPort)"
  }
  $apps = ($clusterConfig.apps + $clusterConfig.config + $clusterConfig.infrastructure) | Sort-Object

  $targets = @()

  foreach($a in $apps)
  {
    if($a -in $links.name -or $a.replace("-"," ") -in $links.name)
    {
      Write-Host "Adding: $a"
      $targets += $links.Where{ $_.name -eq $a -or $_.name.replace(" ","-") -eq $a}
    }
    if($a -in $links.bundle)
    {
      foreach($l in $links.Where{ $_.bundle -eq $a})
      {
        Write-Host "Adding: $($l.name)"
        $targets += $l
      }
    }
  }

  Write-Host "Targets: $($targets.count)"

  $page = Get-Content -Raw -Path "$PSScriptRoot/homer.tpl" | ConvertFrom-Yaml -Ordered

  $page.Title = "$($greek) Cluster"

  foreach($t in $targets | Sort-Object -Property name)
  {
    $logo = switch($t.icon)
    {
      { $_ -like "fa-*" } { $null ; break}
      { $_ -like "http*" } { $_ ; break}
      { $_ -like "*.svg" } { "https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/$($_)" ;break}
      { $_ -like "*.png" } { "https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/png/$($_)"; break}
      default { Write-Error "Unknown link format: $_"}
    }
    if($null -eq $logo)
    {
      $icon = $t.icon
    }
    else
    {
      $icon = $null
    }
    foreach($s in $page.services)
    {
      if($s.name -eq $t.group)
      {
        $o = [ordered]@{
          name = $t.name
          subtitle = $t.description
          url = "https://$($t.address)$($dns)$($webPort)$(if($t.address -eq "homer"){"#$($clusterName)"})"
        }
        if($logo){ $o.add("logo",$logo) } else { $o.add("icon",$icon) }
        $s.items.add($o)
      }
    }
  }

  $page | ConvertTo-Yaml | Out-File -FilePath "$repoRoot/apps/$environment/homer/files/$clusterName.yml"

}


