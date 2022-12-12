#!/bin/sh

export BASEDIR="$HOME/.local/share/photoshop-wine"
export PSPATH="$BASEDIR/Photoshop"
export RESOURCESPATH="$BASEDIR/temp"
export WINEARCH=win32
export WINEPREFIX="$BASEDIR/WINE.$WINEARCH"
export WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree=d"
export LC_ALL=en_US.UTF-8

mkdir -pv "$RESOURCESPATH"

for format in pngfile jpegfile giffile ; do
    cat << EOT > "$RESOURCESPATH/mime-$format.reg"
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\\$format\\shell\\open\\command]
@="\"Z:$PSPATH\\\\Photoshop.exe\" \"%1\""

[-HKEY_CLASSES_ROOT\\$format\\shell\\open\\ddeexec]

EOT
    sed -i 's|/|\\\\|g' "$RESOURCESPATH/mime-$format.reg"
    wine regedit "$RESOURCESPATH/mime-$format.reg"
done; unset format

rm -rv "$RESOURCESPATH"
