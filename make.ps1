param(
    [string[]]$Include,
    [string[]]$Exclude,
    [string[]]$Delist,
    [switch]$All,
    [switch]$Clean
)

$ErrorActionPreference = 'Stop'

$reservedFolderNames = @(
    'includes',
    'repository',
    'scripts'
)

$makefile = Import-PowerShellDataFile -Path make.psd1 -ErrorAction Continue;

$Include = @($Include) + @($makefile.Include);
$Exclude = @($Exclude) + @($makefile.Exclude);
$Delist = @($Delist) + @($makefile.Delist);

$includes = Join-Path $PWD 'includes';

Install-Module -Name powershell-yaml -Force -ErrorAction SilentlyContinue;

$z88dk = (Join-Path $includes 'z88dk');

<# GLOBAL FUNCTIONS #>

function In([array]$list, [string]$name){
    $should = $false;
    foreach ($item in $list) {
        if ($name -like $item) {
            $should = $true;
        }
    }
    return $should;
}

function Include([string]$name) {
    return (In $Include $name);
}

function Exclude([string]$name){
    return (In $Exclude $name);
}

function SetEnvironment([string]$name, [string]$value) {
    [System.Environment]::SetEnvironmentVariable($name, $value, 'Process');
}

function Pull([string]$name, [string]$packageId, [hashtable]$arguments = @{}) {
    $pullScript = Get-ChildItem -Path ./scripts/pull -Filter "$name.ps1" -File;
    Write-Warning "Pull: $name";
    &"$pullScript" $packageId @arguments;
}

function CleanUp([string[]] $paths) {
    foreach ($path in $paths) {
        if ($Clean.IsPresent -and (Test-Path $path)) {
            if ([System.IO.Directory]::Exists($path)) {
                Remove-Item -Path $path -Force -Recurse;
            } else {
                Remove-Item -Path $path -Force;
            }
         }
    }
}

function InFolder([string]$path, [scriptblock]$action){
    $returnTo = $PWD;
        Set-Location $path;
        &$action;
        Set-Location $returnTo;
}

function CloneOrPull([string]$url, [string]$path){
    if (-not (Test-Path $path)) {
        git clone $url $path;
    } else {
        InFolder $path { git pull };
    }
}

<# END FUNCTIONS #>

<# MAKE Scripts #>

$makeFiles = Get-ChildItem -Path ./scripts/make -Filter "*.ps1" -File;
foreach ($file in $makeFiles) {
    $name = $file.BaseName;
    if (-not (Exclude $name) -and ($All.IsPresent -or (Include $name))){
        Write-Warning "Make: $name";
        &"$file";
    }
}

<# Packaging #>

$repo = Join-Path $PWD 'repository';
if (!(Test-Path $repo)){
    New-Item -Path $repo -ItemType Directory;
}

$manifests = @();

$dirs = get-childitem . -Directory | Where-Object Name -notin $reservedFolderNames;

foreach ($dir in $dirs){
    $name = $dir.Name;
    if ((Exclude $name)) { 
        Write-Warning "Skipping $name"
        continue; 
    } else {
        Write-Warning "Found $name"
    }

    $outName = "$($name).napa";
    $jsonPath = Join-Path $dir.FullName 'napa.json';
    $yamlPath = Join-Path $dir.FullName 'napa.yaml';

    $jsonExists = Test-Path $jsonPath;
    $yamlExists = Test-Path $yamlPath;

    if (!$jsonExists -and !$yamlExists) {
        Write-Warning " - No manifest found for $($name)" -ForegroundColor Red;
        continue;
    }

    if ($yamlExists) {
        Write-Warning " - Found YAML";
        $manifest = ConvertFrom-Yaml -Yaml (Get-Content $yamlPath -Raw);
        
    } elseif ($jsonExists) {
        Write-Warning " - Found JSON";
        $manifest = Get-Content $jsonPath -Raw | ConvertFrom-Json -AsHashtable;
    }

    $manifest['path'] = $outName;
    Write-Host ($manifest | out-string);
    
    if (-not (In $Delist $name)) {
        $manifests += $manifest;
    }

    if ($yamlExists) {
        Write-Warning " - Writing JSON";
        $manifest | ConvertTo-Json -Depth 100 | Out-File $jsonPath -Force;
    } 

    $outPath = Join-Path $repo $outName;
    if ((Test-Path $outPath)) {
        Remove-Item -Path $outPath -Force -ErrorAction Continue;
    }
    Write-Warning " - Creating $outName"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($dir.Fullname,$outPath);

    if ($yamlExists) {
        Write-Warning " - Removing JSON";
        Remove-Item -Path $jsonPath -Force;
    }
}

ConvertTo-Json $manifests -Depth 100 `
| Out-File (Join-Path $repo 'repo.json') -Force;

if ($Clean.IsPresent -and (Test-Path $z88dk)) {
   Remove-Item -Path $z88dk -Force -Recurse;
}