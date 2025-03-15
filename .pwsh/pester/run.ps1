Install-Module -Name Pester -MinimumVersion "5.6.1" -Force
Install-Module -Name powershell-yaml -Force

Import-Module -Name Pester -MinimumVersion "5.6.1"
Import-Module -Name powershell-yaml

$cfg = New-PesterConfiguration

# $cfg.Filter.Tag              = 'kustomization'
$cfg.Output.Verbosity        = "Detailed"
# $cfg.Output.Verbosity        = "Normal"
$cfg.Run.Path                = "$PSScriptRoot/*.tests.ps1"
$cfg.TestResult.OutputFormat = "NUnitXml"
$cfg.TestResult.OutputPath   = "$PSScriptRoot/results.xml"
$cfg.TestResult.Enabled      = $True

Invoke-Pester -Configuration $cfg