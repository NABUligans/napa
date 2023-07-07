param(
    [string]$Version = "3.5",
    [string]$PackageId = "nns-bundle-productiondave-nabugames",
    [string]$RepoUrl = "https://github.com/linuxplayground/nabu-games"
)

$url = "$RepoUrl/releases/download/v${Version}/nabu-games-v${Version}.zip"
$MinorVersion = (Get-Date).ToString("yyMMddHHmm");
$Version = "$Version.$MinorVersion";

$outFile = "nabu-games.zip"

$storage = Join-Path $PackageId storage
$B1 = Join-Path $storage 'B1';
$programs = Join-Path $PackageId programs
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) $PackageId;
if((Test-Path $PackageId)) {
    Remove-Item $PackageId -Force -Recurse;
}

New-Item -Path $tmp -ItemType Directory;
New-Item -Path $PackageId -ItemType Directory;
New-Item -Path $programs -ItemType Directory;
New-Item -Path $storage -ItemType Directory;
New-Item -Path $B1 -ItemType Directory;

Invoke-WebRequest -Uri $url -OutFile $outFile
Expand-Archive $outFile -DestinationPath $tmp;

$dirs = Get-ChildItem -Path $tmp -Directory;
$entries = @();
foreach ($dir in $dirs) {
  Copy-Item -Path (Join-Path $dir.FullName "$($dir.Name.ToUpper()).COM") -Destination $B1 -Force;
  $displayName = [cultureinfo]::InvariantCulture.TextInfo.ToTitleCase($dir.Name);
  $name = $dir.Name;
  Copy-Item -Path (Join-Path $dir.FullName '000001.NABU') -Destination (Join-Path $programs "${name}.nabu") -Force;
  #$entries += @{"name" = $name; "path" = "${name}.nabu"};
  $entries += "    - name: ${displayName}"
  $entries += "      path: '${name}.nabu'"
}
<#
Copy-Item -Path (Join-Path $tmp 'invaders' 'INVADERS.COM') -Destination $B1 -Force;
Copy-Item -Path (Join-Path $tmp 'snake' 'SNAKE.COM') -Destination $B1 -Force;
Copy-Item -Path (Join-Path $tmp 'tetris' 'TETRIS.COM') -Destination $B1 -Force;
Copy-Item -Path (Join-Path $tmp 'invaders' '000001.NABU') -Destination (Join-Path $programs 'Invaders.nabu') -Force;
Copy-Item -Path (Join-Path $tmp 'snake' '000001.NABU') -Destination (Join-Path $programs 'Snake.nabu') -Force;
Copy-Item -Path (Join-Path $tmp 'tetris' '000001.NABU') -Destination (Join-Path $programs 'Tetris.nabu') -Force;
#>
#$programEntries = @();
#foreach ($program in $entries) {
#  $programEntries += "    - name: $($program.name)"
#  $programEntries += "      path: '$($program.path)'"
#}
@"
id: $PackageId
name: Production Dave's Nabu Games
description: |
  A collection of games for the Nabu (and Z80 Retro) by Production Dave.
author: Production Dave
version: $Version
url: '$RepoUrl'
manifest:
  programs:
$($entries -join "`n")
"@ | Out-File -Path (Join-Path $PackageId 'napa.yaml') -Force;

Remove-Item $outFile -Force;
Remove-Item $tmp -Recurse -Force;