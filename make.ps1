[cmdletbinding()]
param(
    
    [string[]]$Include,
    [string[]]$Exclude,
    [string[]]$Delist,
    [string]$Label,
    [switch]$All,
    [switch]$Clean
)

$root = $PWD;
$ErrorActionPreference = 'Stop'
$seperator = [System.IO.Path]::PathSeparator;
$reservedFolderNames = @(
    'includes',
    'repository',
    'scripts',
    'temp'
)

$NotNull = { $null -ne $_ }

$makefile = Import-PowerShellDataFile -Path make.psd1 -ErrorAction Continue;
$Label = [string]::IsNullOrWhiteSpace($Label) ? $makefile.Label : $Label;
$Include = @($Include) + @($makefile.Include) | Where-Object $NotNull;
$Exclude = @($Exclude) + @($makefile.Exclude) | Where-Object $NotNull;
$Delist = @($Delist) + @($makefile.Delist) | Where-Object $NotNull;

Write-Warning "Label: $Label";
Write-Warning "Include: $($Include -join ',')"
Write-Warning "Exclude: $($Exclude -join ',')"
Write-Warning "Delist: $($Delist -join ',')"
Write-Warning "All: $($All.IsPresent)"
Write-Warning "Clean: $($Clean.IsPresent)"

$includes = Join-Path $PWD 'includes';

Install-Module -Name powershell-yaml -Force -ErrorAction SilentlyContinue;

$z88dk = (Join-Path $includes 'z88dk');

<# GLOBAL FUNCTIONS #>

$makeScriptPath = Join-Path $PWD 'scripts' 'make';
$pullScriptPath = Join-Path $PWD 'scripts' 'pull';

function In([array]$list, [string]$name){
    
    foreach ($item in $list) {
        if ($name -like $item) {
            return $true;
        }
    }
    return $false;
}

function Include([string]$name) {
    return (In $Include $name);
}

function Exclude([string]$name){
    return (In $Exclude $name);
}

function AddPath([string]$path) {
    $newPath = "${path}${seperator}$env:PATH";
    SetEnvironment PATH $newPath;
}


function RemovePath([string]$path) {
    $newPath = "$env:PATH".Replace(
            $path, [string]::Empty
        ).Replace(
            "${seperator}${seperator}", 
            $seperator
        );
    SetEnvironment PATH $newPath;
}

function SetEnvironment([string]$name, [string]$value) {
    [System.Environment]::SetEnvironmentVariable($name, $value);
}

function Pull([string]$name, [string]$packageId, [hashtable]$arguments = @{}) {
    $pullScript = Get-ChildItem -Path $pullScriptPath -Filter "$name.ps1" -File;
    Write-Warning "Pull: $name";
    &"$pullScript" $packageId @arguments;
}

function Make([string]$name, [hashtable]$arguments = @{}) {
    $makeFile = Get-ChildItem -Path $makeScriptPath -Filter "${name}.ps1" -File;
    Write-Warning "Make: $name";
    &"$makeFile" @arguments;
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



$makeFiles = Get-ChildItem -Path $makeScriptPath -Filter "*.ps1" -File | ForEach-Object { $_.BaseName };
foreach ($file in $makeFiles) {
    if (-not (Exclude $file)){
        Make $file;
    }
}

<# Packaging #>

$repo = Join-Path $PWD 'repository' $Label;
if (!(Test-Path $repo)){
    New-Item -Path $repo -ItemType Directory | Out-Null;
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
        Write-Warning " - No manifest found for $($name)";
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