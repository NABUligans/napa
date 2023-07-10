param(
    [string]$PackageId = "nns-bundle-productiondave-nabugames",
    [string]$Version = "3.5",
    [string]$RepoUrl = "https://github.com/linuxplayground/nabu-games"
)


$MinorVersion = 3;
$entries = Pull 'nabugames' $PackageId @{Version=$Version;RepoUrl=$RepoUrl};
$Version = "$Version.$MinorVersion";

@"
id: $PackageId
name: Production Dave's Nabu Games
description: |
  A collection of games for the Nabu (and Z80 Retro) by Production Dave.
author: Production Dave
version: $Version
url: '$RepoUrl'
manifest:
  programs:
$($entries -join "`n")
"@ | Out-File -Path (Join-Path $PackageId 'napa.yaml') -Force;