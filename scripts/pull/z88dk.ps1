param(
    [string]$PackageId = "",
    [string]$Version = "2.2"
)

$includes = Join-Path $PWD 'includes';
$z88dkZip = (Join-Path $includes 'z88dk.zip');
$z88dk = (Join-Path $includes 'z88dk');

if ((Test-Path $z88dk)) { return; }

$z88dkUrl = "https://github.com/z88dk/z88dk/releases/download/v$Version/z88dk-win32-$Version.zip";
Invoke-WebRequest -Uri $z88dkUrl -OutFile $z88dkZip;
Expand-Archive -Path $z88dkZip -DestinationPath $includes;
Remove-Item $z88dkZip -Force;

#$env:PATH = "$z88dk\bin;$env:PATH";
#$env:ZCCCFG = "$z88dk\lib\config";
SetEnvironment PATH "$z88dk\bin;$env:PATH";
SetEnvironment ZCCCFG "$z88dk\lib\config";