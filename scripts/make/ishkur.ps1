param (
    [string]$PackageId = 'nns-bundle-ishkurcpm',
    [string]$MajorVersion = '0.1'
)

$MinorVersion = (Get-Date).ToString("yyMMddHHmm");
$Version = "$MajorVersion.$MinorVersion";

Pull 'ishkur' $PackageId;

@"
id: $PackageId
name: Ishkur CPM
description: |
  Ishkur is a flavor of CPM 2.2 made for the NABU from the ground up. System files are loaded via NHACP. 
  This is the 'hybrid' flavor, and supports real drives (C & D) as well as cloud disks (A,B,E,etc).
author: teragav17
version: $Version
url: 'https://github.com/tergav17/IshkurCPM'
manifest:
  programs:
    - path: NFS_HYBRID_BOOT.nabu
      name: Ishkur CPM NFS
    - path: NDSK_HYBRID_BOOT.nabu
      name: Ishkur CPM NDSK
    - path: IDE_BOOT.nabu
      name: Ishkur CPM IDE
  storage:
    - path: NDSK_A.IMG
      options:
        updatetype: copy
    - path: NDSK_B.IMG
      options:
        updatetype: copy
features:
  NHACPv01: true
"@ | Out-File -Path (Join-Path $PackageId 'napa.yaml') -Force;


