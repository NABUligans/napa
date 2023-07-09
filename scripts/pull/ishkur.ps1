param (
    [string]$PackageId
    #[string]$MajorVersion
)

#$MinorVersion = (Get-Date).ToString("yyMMddHHmm");
#$Version = "$MajorVersion.$MinorVersion";

$includes = Join-Path $PWD 'includes'
$outPath = Join-Path $includes 'IshkurCPM'
git clone 'https://github.com/tergav17/IshkurCPM.git' $outPath;
$storage = Join-Path $PackageId storage
$programs = Join-Path $PackageId programs
if((Test-Path $PackageId)) {
    Remove-Item $PackageId -Force -Recurse;
}

$tmp = [System.IO.Path]::GetTempPath();

$A0 = Join-Path $storage A0;
$B0 = Join-Path $storage B0;
$M0 = Join-Path $storage M0;

New-Item -Path $PackageId -ItemType Directory | Out-Null
New-Item -Path $storage -ItemType Directory | Out-Null;
New-Item -Path $A0 -ItemType Directory | Out-Null;
New-Item -Path $M0 -ItemType Directory | Out-Null;
New-Item -Path $programs -ItemType Directory | Out-Null;

$diskContent = Join-Path $outPath 'Directory';
$programSource = Join-Path $outPath 'Output';
$apps = Join-Path $outPath "/Applications/Premade";
$ptxplay = Join-Path $outPath "/Applications/Misc/PtxPlay";
$msxrom = Join-Path $includes "msxrom";
$blankNDSK = Join-Path $includes "/ndsk/NDSK_B.IMG";
$idegen = Join-Path $outPath "/Applications/Misc/IDEGen/idegen.com"

$ndsk = Join-Path $programSource 'NABU_NDSK';
$nfs = Join-Path $programSource 'NABU_NFS';
$ide = Join-Path $programSource 'NABU_IDE';

#Programs
Get-ChildItem -Path $ndsk -Filter "NDSK_HYBRID_BOOT.nabu" | Copy-Item -Destination $programs -Force;
Get-ChildItem -Path $nfs -Filter "NFS_HYBRID_BOOT.nabu" | Copy-Item -Destination $programs -Force;
Get-ChildItem -Path $ide -Filter "IDE_BOOT.nabu" | Copy-Item -Destination $programs -Force;

#NDSK
Copy-Item -Path (Join-Path $ndsk NDSK_HYBRID_CPM22.SYS) -Destination (Join-Path $storage 'CPM22.SYS') -Force;
Copy-Item -Path (Join-Path $programSource FONT.GRB) -Destination $storage -Force;
Copy-Item -Path (Join-Path $ndsk NDSK_DEFAULT.IMG) -Destination (Join-Path $storage 'NDSK_A.IMG') -Force;
Copy-Item -Path $blankNDSK -Destination (Join-Path $storage 'NDSK_B.IMG') -Force;
#NFS
Copy-Item -Path (Join-Path $nfs NFS_HYBRID_CPM22.SYS) -Destination (Join-Path $A0 'CPM22.SYS') -Force;
Copy-Item -Path (Join-Path $programSource FONT.GRB) -Destination $A0 -Force;
Copy-Item -Path (Join-Path $diskContent *) -Destination $A0 -Force;

#IDE
Copy-Item -Path $idegen -Destination (Join-Path $A0 'idegen.com') -Force;

Copy-Item -Path (Join-Path $msxrom *) -Destination $M0 -Force;
Expand-Archive (join-path $M0 'samples.wad') -DestinationPath $M0 -Force;
Remove-Item (join-path $M0 'samples.wad');

Expand-Archive (join-path $apps CPMSoftware.zip) -DestinationPath $tmp -Force
Move-Item -Path (Join-Path $tmp 'CPMSoftware_Updated' '*') -Destination $storage -Force;

Copy-Item -Path (Join-Path $ptxplay 'ptxplay.com') -Destination (Join-Path $B0 'ptxplay.com') -Force;

Remove-Item $outPath -Force -Recurse;