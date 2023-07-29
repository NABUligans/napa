
function EnsureFolder([string]$Path) {
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -ItemType Directory;
    }
}

function ArchiveFolder([string]$Path,[string]$PackagesFolder) {
    $archiveFolder = Join-Path $PackagesFolder 'archive';
    EnsureFolder $archiveFolder;
    $name = [System.IO.Path]::GetFileName($Path);
    $filename = "${name}-$((Get-Date).ToString("yyyy-MM-dd-HH-mm-ss")).zip";
    Compress-Archive -Path $destination -DestinationPath "$(Join-Path $archiveFolder $filename)";
}

function Install-NAPAPackage {
    [cmdletbinding()]
    param(
        [string]$Package,
        [string]$PackagesFolder
    )
    $ErrorActionPreference = 'Stop';
    
    $name = [System.IO.Path]::GetFileNameWithoutExtension($Package);
    $destination = (Join-Path $PackagesFolder $name);

    if ((Test-Path $destination)){  
        ArchiveFolder $destination $PackagesFolder
        Remove-Item -Path $destination -Force -Recurse;
    } 

    New-Item -Path $destination -ItemType Directory -Force;
    Extract-Archive -Path $Package -DestinationPath $destination;
}

Export-ModuleMember -Cmdlet @(
    'Install-NAPAPackage'
)