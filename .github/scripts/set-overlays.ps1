#Requires -module powershell-yaml
$InformationPreference = "Continue"
$ErrorActionPreference = "Stop"

$repoRoot = "$PSScriptRoot/../.."

$script:templateDir = Resolve-Path (Join-Path -Path $repoRoot -ChildPath "template")
$script:overlayDir = Resolve-Path (Join-Path -Path $repoRoot -ChildPath "overlay")

function Set-Overlay($Name, $Layer, $FilePath){
  if(Test-Path $FilePath)
  {
    Write-Information "${FilePath} exists"
  }
  else
  {
    Write-Information "${FilePath} not found, creating"
    [ordered]@{
      apiVersion = "kustomize.toolkit.fluxcd.io/v1"
      kind = "Kustomization"
      metadata = [ordered]@{
        name = "${name}"
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
        path = "./template/${name}/${layer}"
        prune = $true
        wait = $true
      }
    } | ConvertTo-Yaml | Out-File -NoNewLine -FilePath $filePath
    Write-Information "${FilePath} created"
  }
}

foreach($app in Get-ChildItem -Path $templateDir -Directory)
{
  Write-Information $app.Name
  $layers = Get-ChildItem -Path $app.FullName -Directory -Exclude "base"
  if($layers.count -eq 0)
  {
    # base only
    $overlayPath = Join-Path -Path $overlayDir -ChildPath "$($app.Name).yaml"
    Set-Overlay -Name $app.Name -Layer "base" -FilePath $overlayPath
  }
  else
  {
    # layered
    foreach($layer in $layers.Name)
    {
      $overlayPath = Join-Path -Path $overlayDir -ChildPath $app.Name,"${layer}.yaml"
      Set-Overlay -Name $app.Name -Layer $layer -FilePath $overlayPath
    }
  }
}