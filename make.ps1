param(
    [string[]]$Include,
    [switch]$All,
    [switch]$OnlyNNSBundles,
    [switch]$ExcludeNNSBundles
)

$ErrorActionPreference = 'Stop'

$reservedFolderNames = @(
    'includes',
    'repository',
    'scripts'
)


$nnsFilter = "nns-bundle-*";
$includes = Join-Path $PWD 'includes';

Install-Module -Name powershell-yaml -Force -ErrorAction SilentlyContinue;

$z88dk = (Join-Path $includes 'z88dk');



function Include([string]$name) {
    foreach ($inc in $Include) {
        if ($inc -eq $name) {
            return $true;
        }
    }
    return $false;
}

function SetEnvironment([string]$name, [string]$value) {
    [System.Environment]::SetEnvironmentVariable($name, $value, 'Process');
}

function Pull([string]$name, [string]$packageId, [hashtable]$arguments = @{}) {
    $pullScript = Get-ChildItem -Path ./scripts/pull -Filter "$name.ps1" -File;
    Write-Warning "Pull: $name";
    &"$pullScript" $packageId @arguments;
}



$makeFiles = Get-ChildItem -Path ./scripts/make -Filter "*.ps1" -File;
foreach ($file in $makeFiles) {
    $name = $file.BaseName;
    if ($All.IsPresent -or (Include $name)) {
        Write-Warning "Make: $name";
        &"$file";
    }
}

$repo = Join-Path $PWD 'repository';
if (!(Test-Path $repo)){
    New-Item -Path $repo -ItemType Directory;
}
$manifests = @();

if ($OnlyNNSBundles.IsPresent) {
    $dirs = get-childitem . -Filter $nnsFilter -Directory
} else {
    $dirs = get-childitem . -Directory | Where-Object Name -notin $reservedFolderNames;

    if ($ExcludeNNSBundles.IsPresent) {
        $dirs | Where-Object Name -notlike $nnsFilter
    }
}

foreach ($dir in $dirs){
    $outName = "$($dir.Name).napa";
    $jsonPath = Join-Path $dir.FullName 'napa.json';
    $yamlPath = Join-Path $dir.FullName 'napa.yaml';

    $jsonExists = Test-Path $jsonPath;
    $yamlExists = Test-Path $yamlPath;

    if (!$jsonExists -and !$yamlExists) {
        Write-Warning "No manifest found for $($dir.Name)" -ForegroundColor Red;
        continue;
    }

    if ($yamlExists) {
        Write-Warning "Found YAML";
        $manifest = ConvertFrom-Yaml -Yaml (Get-Content $yamlPath -Raw);
        
    } elseif ($jsonExists) {
        Write-Warning "Found JSON";
        $manifest = Get-Content $jsonPath -Raw | ConvertFrom-Json -AsHashtable;
    }

    $manifest['path'] = $outName;
    Write-Host ($manifest | out-string);
    
    $manifests += $manifest;

    if ($yamlExists) {
        Write-Warning "Writing JSON";
        $manifest | ConvertTo-Json -Depth 100 | Out-File $jsonPath -Force;
    } 

    $outPath = Join-Path $repo $outName;
    if ((Test-Path $outPath)) {
        Remove-Item -Path $outPath -Force -ErrorAction Continue;
    }
    Write-Warning "Creating $outName"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($dir.Fullname,$outPath);

    if ($yamlExists) {
        Write-Warning "Removing JSON";
        Remove-Item -Path $jsonPath -Force;
    }
}

ConvertTo-Json $manifests -Depth 100 `
| Out-File (Join-Path $repo 'repo.json') -Force;

#if ((Test-Path $z88dk)) {
#   Remove-Item -Path $z88dk -Force -Recurse;
#|