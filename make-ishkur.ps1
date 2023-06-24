param (
    [string]$PackageId = 'nns-bundle-ishkurcpm',
    [string]$MajorVersion = '0.1'
)

$MinorVersion = (Get-Date).ToString("yyMMddHHmm");
$Version = "$MajorVersion.$MinorVersion";

git clone 'https://github.com/tergav17/IshkurCPM.git';
$storage = Join-Path $PackageId storage
$programs = Join-Path $PackageId programs
if((Test-Path $PackageId)) {
    Remove-Item $PackageId -Force -Recurse;
}

$tmp = [System.IO.Path]::GetTempPath();

$A0 = Join-Path $storage A0;
$B0 = Join-Path $storage B0;
$M0 = Join-Path $storage M0;

New-Item -Path $PackageId -ItemType Directory
New-Item -Path $storage -ItemType Directory;
New-Item -Path $A0 -ItemType Directory;
New-Item -Path $M0 -ItemType Directory;
New-Item -Path $programs -ItemType Directory;

$diskContent = "./IshkurCPM/Directory";
$programSource = "./IshkurCPM/Output";
$apps = "./IshkurCPM/Applications/Premade";
$ptxplay = "./IshkurCPM/Applications/Misc/PtxPlay";
$msxrom = "./includes/msxrom";

$ndsk = Join-Path $programSource 'NABU_NDSK';
$nfs = Join-Path $programSource 'NABU_NFS';

#Programs
Get-ChildItem -Path $ndsk -Filter "NDSK_HYBRID_BOOT.nabu" | Copy-Item -Destination $programs -Force;
Get-ChildItem -Path $nfs -Filter "NFS_HYBRID_BOOT.nabu" | Copy-Item -Destination $programs -Force;

#NDSK
Copy-Item -Path (Join-Path $ndsk NDSK_HYBRID_CPM22.SYS) -Destination (Join-Path $storage 'CPM22.SYS') -Force;
Copy-Item -Path (Join-Path $programSource FONT.GRB) -Destination $storage -Force;
Copy-Item -Path (Join-Path $ndsk NDSK_DEFAULT.IMG) -Destination (Join-Path $storage 'NDSK_A.IMG') -Force;

#NFS
Copy-Item -Path (Join-Path $nfs NFS_HYBRID_CPM22.SYS) -Destination (Join-Path $A0 'CPM22.SYS') -Force;
Copy-Item -Path (Join-Path $programSource FONT.GRB) -Destination $A0 -Force;
Copy-Item -Path (Join-Path $diskContent *) -Destination $A0 -Force;

Copy-Item -Path (Join-Path $msxrom *) -Destination $M0 -Force;
Expand-Archive (join-path $M0 'samples.wad') -DestinationPath $M0 -Force
Remove-Item (join-path $M0 'samples.wad')

Expand-Archive (join-path $apps CPMSoftware.zip) -DestinationPath $tmp -Force
Move-Item -Path (Join-Path $tmp 'CPMSoftware_Updated' '*') -Destination $storage -Force;

Copy-Item -Path (Join-Path $ptxplay 'ptxplay.com') -Destination (Join-Path $B0 'ptxplay.com') -Force;

@"
id: $PackageId
name: Ishkur CPM
description: |
  Ishkur is a flavor of CPM 2.2 made for the NABU from the ground up. System files are loaded via NHACP. 
  This is the 'hybrid' flavor, and supports real drives (C & D) as well as cloud disks (A,B,E,etc).
author: teragav17
version: $Version
manifest:
  programs:
    - path: NFS_HYBRID_BOOT.nabu
      name: Ishkur CPM NFS
    - path: NDSK_HYBRID_BOOT.nabu
      name: Ishkur CPM NDSK
  storage:
    - path: NDSK_A.IMG
      options:
        updatetype: copy
features:
  NHACPv01: true
"@ | Out-File -Path (Join-Path $PackageId 'napa.yaml') -Force;

Remove-Item IshkurCPM -Force -Recurse;
