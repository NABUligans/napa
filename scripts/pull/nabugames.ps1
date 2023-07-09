param(
    [string]$PackageId = "nns-bundle-productiondave-nabugames",
    [string]$Version = "3.5",
    [string]$RepoUrl = "https://github.com/linuxplayground/nabu-games"
)


#$MinorVersion = (Get-Date).ToString("yyMMddHHmm");
#$Version = "$Version.$MinorVersion";
$entries = @();

$url = "$RepoUrl/releases/download/v${Version}/nabu-games-v${Version}.zip"
$outFile = Join-Path $PWD "includes/nabu-games.zip"

Write-Warning "Downloading $url to $outFile"

$storage = Join-Path $PackageId storage
$B1 = Join-Path $storage 'B1';
$programs = Join-Path $PackageId programs
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) $PackageId;
if ((Test-Path $PackageId)) {
    Remove-Item $PackageId -Force -Recurse | Out-Null;
}
if ((Test-Path $tmp)) {
    Remove-Item $tmp -Force -Recurse | Out-Null;
}

New-Item -Path $tmp -ItemType Directory | Out-Null;
New-Item -Path $PackageId -ItemType Directory | Out-Null;
New-Item -Path $programs -ItemType Directory | Out-Null;
New-Item -Path $storage -ItemType Directory | Out-Null;
New-Item -Path $B1 -ItemType Directory | Out-Null;

Invoke-WebRequest -Uri $url -OutFile $outFile;
Expand-Archive $outFile -DestinationPath $tmp

$dirs = Get-ChildItem -Path $tmp -Directory;

foreach ($dir in $dirs) {
    Copy-Item -Path (Join-Path $dir.FullName "$($dir.Name.ToUpper()).COM") -Destination $B1 -Force;
    $displayName = [cultureinfo]::InvariantCulture.TextInfo.ToTitleCase($dir.Name);
    $name = $dir.Name;
    Copy-Item -Path (Join-Path $dir.FullName '000001.NABU') -Destination (Join-Path $programs "${name}.nabu") -Force;
    #$entries += @{"name" = $name; "path" = "${name}.nabu"};
    $entries += "    - name: ${displayName}"
    $entries += "      path: '${name}.nabu'"
}

Remove-Item $outFile -Force;
Remove-Item $tmp -Recurse -Force;


return $entries;