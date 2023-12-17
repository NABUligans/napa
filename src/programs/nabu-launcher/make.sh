#!/bin/sh

TARGET="${1:-"all"}"

export PATH=${PATH}:${HOME}/z88dk/bin
export ZCCCFG=${HOME}/z88dk/lib/config
eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)

make clean && make $TARGET

cp -f LAUNCHER.NABU '/mnt/c/Users/nickd/OneDrive/Repos/NabuNetworkEmulator/Nabu.NetSimWeb/bin/Debug/net7.0/Packages/nns-nabu-launcher/paks/launcher/000001.nabu'
cp -f LAUNCHER.NABU '../../nns-nabu-launcher/paks/launcher/000001.nabu'
cp -f TEST.NABU '/mnt/c/NABU/NABUs/Menu Test.nabu'