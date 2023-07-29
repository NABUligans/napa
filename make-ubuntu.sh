chmod +x ./scripts/pull/pwsh-ubuntu.sh
./scripts/pull/pwsh-ubuntu.sh
#clear
pwsh -command "&{ ./make.ps1 $@ }"