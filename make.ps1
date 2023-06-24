param(
    [switch]$Ishkur,
    [switch]$NabuGames,
    [switch]$All,
    [switch]$OnlyNNSBundles,
    [switch]$ExcludeNNSBundles
)


if ($Ishkur.IsPresent -or $All.IsPresent)
{ 
    .\make-ishkur.ps1;
}

if ($NabuGames.IsPresent -or $All.IsPresent)
{ 
    .\make-nabugames.ps1;
}

$repo = Join-Path $PWD 'repository';
if (!(Test-Path $repo)){
    New-Item -Path $repo -ItemType Directory;
}
$manifests = @();

if ($OnlyNNSBundles.IsPresent) {
    $dirs = get-childitem . -Filter "nns-bundle-*" -Directory
} else {
    $dirs = get-childitem . -Directory `
            | Where-Object Name -ne 'includes' `
            | Where-Object Name -ne 'repository';

    if ($ExcludeNNSBundles.IsPresent) {
        $dirs | Where-Object Name -notlike "nns-bundle-*"
    }
}

foreach ($dir in $dirs){
    $outName = "$($dir.Name).napa";
    $outPath = Join-Path $repo $outName;
    $manifests += (Get-Content (Join-Path $dir.FullName 'napa.yaml') -Raw) + "`npath: $outName";
    
    Remove-Item -Path $outPath -Force -ErrorAction SilentlyContinue;
    [System.IO.Compression.ZipFile]::CreateFromDirectory($dir.Fullname,$outPath);
}

#Copy-Item -Path './includes/news.yaml' -Destination $repo -Force;
[string]::Join("`n---`n", $manifests) | Out-File (Join-Path $repo 'repo.yaml') -Force;