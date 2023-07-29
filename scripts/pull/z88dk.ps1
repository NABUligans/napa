param(
    [string]$PackageId = "",
    [string]$Version = 'latest'
)

$includes = Join-Path $PWD 'includes';
$z88dkZip = (Join-Path $includes 'z88dk.zip');
$z88dk = (Join-Path $includes 'z88dk');

if ((Test-Path $z88dk)) { return; }

switch ([System.Runtime.InteropServices.RuntimeInformation]::OSDescription) {
    #{ $_.Contains('macOS')} { $OS = 'osx' }
    { $_.Contains('linux')} { 
        $OS = 'linux';
    }
    default {
        $OS = 'win32'
    }
}
if ($null -ne $OS) {
    
    if ($Version -eq 'latest') {
        if ($OS -eq 'linux') {
            $z88dkUrl = 'http://nightly.z88dk.org/z88dk-latest.tgz'
        } else {
            $z88dkUrl = 'http://nightly.z88dk.org/z88dk-$OS-latest.zip'
        }
    } else {
        if ($OS -eq 'linux') {
            $z88dkUrl = "https://github.com/z88dk/z88dk/releases/download/v$Version/z88dk-src-$Version.tgz"
        } else {
            $z88dkUrl = "https://github.com/z88dk/z88dk/releases/download/v$Version/z88dk-$OS-$Version.zip";
        }
    }

} else {
    throw "Only Windows and macOS are currently supported"
    return;
}

Invoke-WebRequest -Uri $z88dkUrl -OutFile $z88dkZip;
if ($OS -ne 'linux') {
    Expand-Archive -Path $z88dkZip -DestinationPath $includes;
    AddPath "$z88dk\bin";
    SetEnvironment ZCCCFG "$z88dk\lib\config";
} else {
    $linuxDetails = "$(lsb_release -a)";

    if ($linuxDetails.Contains('ubuntu')) {
        InFolder $z88dk {
            sh "$(Join-Path $makeScriptPath 'z88dk' 'ubuntu.sh')";
        };
    }
}
CleanUp $z88dkZip;

#$env:PATH = "$z88dk\bin;$env:PATH";
#$env:ZCCCFG = "$z88dk\lib\config";
