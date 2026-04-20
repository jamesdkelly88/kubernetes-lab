#Requires -Module Pester -Version 5
#Requires -Module powershell-yaml

BeforeDiscovery {
  
  $TopFolders = @("apps","clusters","infrastructure")
  $ExcludeFolders = @("charts","files")
  $ExcludeFiles = @("kustomizeconfig.yaml","values.yaml")
  $RepositoryRoot = Resolve-Path -Path "$PSScriptRoot/../.."
  Write-Verbose "Repo root: $($RepositoryRoot)"

  $folders = @()
  $files = @()

  $folders = [System.Collections.ArrayList]::new()

  foreach($t in $TopFolders)
  {
    Write-Verbose "TopFolder: $t"
    $SubFolders = Get-ChildItem -Path (Join-Path $RepositoryRoot $t) -Recurse -Directory
    Write-Verbose "Subfolders: $($SubFolders.count)"
    foreach($s in $SubFolders)
    {
      if($s.name -in $ExcludeFolders) { continue }
      Write-Verbose "Subfolder: $s"
      $Files = (Get-ChildItem -Path $s -File).Where{ $_.Extension -in @(".yaml",".yml")}
      Write-Verbose "Files: $($Files.count)"
      if($Files.count -eq 0) { continue }

      [array]$FileData = foreach($f in $Files)
      {
        if($f.Name -in $ExcludeFiles){ continue }
        $h = [hashtable]@{
          Name = $f.Name
          BaseName = $f.BaseName
          Extension = $f.Extension
          Parent = $f.DirectoryName
          Path = $f.FullName.Replace($RepositoryRoot,'')
          AbsolutePath = $f.FullName
          Yaml = $null
          IsManifest = ($f.Name -notin $ExcludeFiles)
          Kind = $null
        }
        try {
            $h.Yaml = (Get-Content -Path $f.FullName -Raw) | ConvertFrom-Yaml -Ordered -AllDocuments
        }
        catch {}
        try {
            $h.Kind = $h.Yaml["kind"]
        }
        catch {}
        $h
      }

      $folders.add([PSCustomObject]@{
        Path = $s.FullName
        Files = $Files.Count
        Data = $FileData
      })
    }
  }

  $files = $folders.data
  Write-Verbose "Files: $($files.count)"

  

}

Describe "Kubernetes manifests" {
  Context "File: <path>" -ForEach($files) -Tag "file" {
      It "has extension .yaml" {
          $Extension | Should -BeExactly ".yaml"
      }

      It "is valid YAML" {
          $Yaml | Should -Not -Be $null
      }

      It "contains a single document" {
          $Yaml.GetType().Name | Should -Be "OrderedDictionary"
      }
  }

  Context "Manifest: <path>" -Foreach($files.Where{ $_.IsManifest }) -Tag "manifest" {

      It "has apiVersion as the first key" {
          $Yaml.Keys[0] | Should -BeExactly "apiVersion"
      }

      It "has kind as the second key" {
          $Yaml.Keys[1] | Should -BeExactly "kind"
      }
  }

  Context "Namespace: <path>" -ForEach($files.Where{ $_.Kind -eq "namespace"}) -Tag "namespace" {
      It "should be declared as default" {
          $Yaml.metadata.name | Should -BeExactly "default"
      }

      It "has pod security enforcement defined" {
          $Yaml.metadata.labels.keys | Should -Contain "pod-security.kubernetes.io/enforce"
      }

      It "has a valid pod security enforcement" {
          $Yaml.metadata.labels."pod-security.kubernetes.io/enforce" | Should -BeIn @("privileged","baseline","restricted")
      }

      It "has pod security warning defined" {
        $Yaml.metadata.labels.keys | Should -Contain "pod-security.kubernetes.io/warn"
      }

      It "should have pod security warning as restricted" {
        $Yaml.metadata.labels."pod-security.kubernetes.io/warn" | Should -Be "restricted"
      }
  }

  Context "Kustomization: <path>" -ForEach($files.Where{ $_.basename -eq "kustomization"}) -Tag "kustomization" {
      It "should use the v1beta1 api" {
          $Yaml.apiVersion | Should -BeExactly "kustomize.config.k8s.io/v1beta1"
      }

      It "should provide a namespace" {
          $Yaml.namespace | Should -Not -BeNullOrEmpty
      }

      It "should only use resources that exist" -ForEach ($yaml.resources.where{ $_ -notlike "http*" }.Foreach({ $absolutepath.replace("kustomization.yaml",$_) })) {
          $_ | Should -Exist
      }
  }

  Context "HelmRepository: <path>" -ForEach($files.Where{ $_.Kind -eq "HelmRepository"}) -Tag "helmrepository" {
      It "should have namespace set" {
        $Yaml.metadata.namespace | Should -Not -BeNullOrEmpty -Because "Renovate needs this"
      }
  }
}