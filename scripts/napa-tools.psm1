

function Install-NAPAPackage {
    [cmdletbinding()]
    param(
        [string]$Package,
        [string]$PackagesFolder
    )
    $name = [System.IO.Path]::GetFileNameWithoutExtension($Package);
    $destination = (Join-Path $PackagesFolder $name);

    if ((Test-Path $destination)){
        Remove-Item -Path $destination -Force -Recurse;
    } 

    New-Item -Path $destination -ItemType Directory -Force;
    Extract-Archive -Path $Package -DestinationPath $destination;
}

Export-ModuleMember -Cmdlet @(
    'Install-NAPAPackage'
)