[cmdletbinding()]
param ()

$sourcesPath = Join-Path $PSScriptRoot 'sources.psd1'
Write-Warning "$sourcesPath"
$sources = 
    Import-PowerShellDataFile `
        -Path $sourcesPath `
        -ErrorAction Continue;
    

function repoUrl($repoUrl, $branch) {
    return @(
        $repoUrl.TrimEnd('/'),
        'raw'
        $branch
        '.napa'
        'package.napa'
    ) -join '/'
}

foreach ($source in $sources.GetEnumerator()) {
    $repo = $source.Value;
    $url = repoUrl $repo.url $repo.branch;
    Write-Warning "Downloading $url";
    $destination =  (Join-Path $PWD $source.Key);
    if ((Test-Path $destination)) {
        Remove-Item -Path $destination -Recurse -Force;
    }  
    $filename = "$([System.IO.Path]::GetTempFileName()).zip";
    Invoke-WebRequest -Uri $url -OutFile $filename;
    New-Item -ItemType Directory -Path $destination;
    [System.IO.Compression.ZipFile]::ExtractToDirectory($filename, $destination);
}



