chmod +x ./scripts/pull/pwsh.sh
./scripts/pull/pwsh.sh
clear
pwsh -command "&{ ./make.ps1 $@ }"