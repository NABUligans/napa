param(
    [string[]]$Include,
    [switch]$All,
    [switch]$OnlyNNSBundles,
    [switch]$ExcludeNNSBundles
)

Install-Module -Name powershell-yaml -Force -ErrorAction SilentlyContinue;

function Include([string]$name) {
    foreach ($inc in $Include) {
        if ($inc -eq $name) {
            return $true;
        }
    }
    return $false;
}

$makeFiles = Get-ChildItem -Path . -Filter "make-*.ps1" -File;
foreach ($file in $makeFiles) {
    $name = $file.BaseName.Replace("make-", "").Replace(".ps1", "");
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
    Remove-Item -Path $outPath -Force -ErrorAction Continue;
    Write-Warning "Creating $outName"
    [System.IO.Compression.ZipFile]::CreateFromDirectory($dir.Fullname,$outPath);

    if ($yamlExists) {
        Write-Warning "Removing JSON";
        Remove-Item -Path $jsonPath -Force;
    }
}

#$yamlManifests = $manifests | ForEach-Object { $_ | ConvertTo-Yaml; }

#Copy-Item -Path './includes/news.yaml' -Destination $repo -Force;
#[string]::Join("`n---`n", $yamlManifests) `
#| Out-File (Join-Path $repo 'repo.yaml') -Force;

ConvertTo-Json $manifests -Depth 100 `
| Out-File (Join-Path $repo 'repo.json') -Force;