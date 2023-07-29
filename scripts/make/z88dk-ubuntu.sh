z88dk='/usr/local/share/z88dk'
sudo apt update
sudo apt install -y build-essential bison flex libxml2-dev subversion zlib1g-dev m4 ragel re2c dos2unix texinfo texi2html gdb curl cpanminus ccache libboost-all-dev libmodern-perl-perl libyaml-perl liblocal-lib-perl libcapture-tiny-perl libpath-tiny-perl libtext-table-perl libdata-hexdump-perl libregexp-common-perl libclone-perl libfile-slurp-perl
cpanm --local-lib=~/perl5 App::Prove Clone CPU::Z80::Assembler Data::Dump Data::HexDump File::Path List::Uniq Modern::Perl Object::Tiny::RW Regexp::Common Test::Harness Text::Diff Text::Table YAML::Tiny

./build.sh -C -v

cd .. && mv ./z88dk/* $z88dk && cd $z88dk

make BUILD_SDCC=1 BUILD_SDCC_HTTP=1 bin/z88dk-zsdcc