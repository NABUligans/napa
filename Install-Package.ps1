[cmdletbinding()]
param(
    [string]$Package,
    [string]$PackagesFolder
)
$name = [System.IO.Path]::GetFileNameWithoutExtension($Package);
$destination = (Join-Path $PackagesFolder $name);

if (!(Test-Path $destination)){
    New-Item -Path $destination -ItemType Directory -Force;
} else {
    Remove-Item -Path $destination -Force -Recurse;
}

Extract-Archive -Path $Package -DestinationPath $destination;