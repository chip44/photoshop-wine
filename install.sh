#!/bin/sh

#########################
#        Config         #
#########################

# User
export BASEDIR="$HOME/.local/share/photoshop-wine"
export LAUNCHER="$HOME/.local/bin/photoshop"
export DESKTOPFILE="$HOME/.local/share/applications/photoshop.desktop"
export FONTSPATH="$HOME/.local/share/fonts/windows"
export PSPATH="$BASEDIR/Photoshop"
export RESOURCESPATH="$BASEDIR/temp"

# Wine
export WINEARCH=win32
export WINEPREFIX="$BASEDIR/WINE.$WINEARCH"
export WINEDLLOVERRIDES="winemenubuilder.exe=d;mscoree=d"

# Just in case
export LC_ALL=en_US.UTF-8

#########################
#       Functions       #
#########################

# Info
INFO() { printf "\033[0;36m$*\033[0m"; sleep 0.1; }
CHCK() { printf "\033[0;32m$*\033[0m\n"; sleep 0.5; }
WARN() { printf "\033[0;33m$*\033[0m\n"; }
ERRO() { printf "\033[0;31m$*\033[0m\n"; exit 1; }

# Download from google drive
gddl() {
    path="$1"
    fileid="$2"
    html=$(curl -s -c "$RESOURCESPATH/cookie" -L "https://drive.google.com/uc?export=download&id=$fileid")
    curl -s -Lb "$RESOURCESPATH/cookie" "https://drive.google.com/uc?export=download&$(echo "$html" | grep -Po '(confirm=[a-zA-Z0-9\-_]+)')&id=$fileid" -o "$path"
    rm "$RESOURCESPATH/cookie"
}

#########################
#        Execute        #
#########################

# Confirmation
if [ "$(ls -A "$BASEDIR" 2>/dev/null)" ]; then
    WARN "'$BASEDIR' is not empty."
else
    echo "Photoshop will be installed in '$BASEDIR'."
fi
read -rp "Proceed? [y/N] " REPLY
case "$REPLY" in
    y|Y|yes|Yes) continue ;;
    *) exit 0 ;;
esac

INFO "Checking dependencies... \n"
missingdep=0
for dep in wine curl tar ; do
    [ -z "$(command -v $dep)" ] && missingdep=1 && WARN "'$dep' not found" && sleep 0.1
done; unset dep
[ "$missingdep" -ne 0 ] && ERRO "Please install the required dependencies." || CHCK "Done"

# Check for missing fonts
dlfonts=0
missingfont=0
for font in tahoma arial courier comic georgia impact times trebuchet verdana webdings ; do
    [ -z "$(fc-list | grep -i "$font")" ] && missingfont=1 && break
done
if [ "$missingfont" -ne 0 ]; then 
    WARN "You are missing some required fonts for Photoshop." 
    echo "They will be placed in '$FONTSPATH'."
    echo "Download size is ~510MB, 180MB will be freed after extraction."
    echo "(THIS STEP IS OPTIONAL)"
    read -rp "Do you want to download them? [Y/n]" REPLY
    case "$REPLY" in
        n/N/no/NO) continue ;;
        *) dlfonts=1; continue ;;
    esac
fi

INFO "Creating directories... "
for dir in $BASEDIR $WINEPREFIX $PSPATH $RESOURCESPATH $FONTSPATH ; do
    mkdir -p "$dir"
done; unset dir
for dir in $LAUNCHER $DESKTOPFILE ; do
    mkdir -p "$(dirname "$dir")"
done; unset dir
CHCK "Done"

INFO "Generating Wine prefix... "
wineboot -i >/dev/null 2>&1
CHCK "Done"

INFO "Setting up font smoothing... "
cat << 'EOT' > "$RESOURCESPATH/font.reg"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Control Panel\Desktop]
"FontSmoothing"="2"
"FontSmoothingGamma"=dword:00000578
"FontSmoothingOrientation"=dword:00000001
"FontSmoothingType"=dword:00000002
EOT
wine regedit "$RESOURCESPATH/font.reg" >/dev/null 2>&1
CHCK "Done"

INFO "Setting up dark theme... "
cat << 'EOT' > "$RESOURCESPATH/theme.reg"
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Control Panel\Colors]
"ActiveBorder"="49 54 58"
"ActiveTitle"="49 54 58"
"AppWorkSpace"="60 64 72"
"Background"="49 54 58"
"ButtonAlternativeFace"="200 0 0"
"ButtonDkShadow"="154 154 154"
"ButtonFace"="49 54 58"
"ButtonHilight"="119 126 140"
"ButtonLight"="60 64 72"
"ButtonShadow"="60 64 72"
"ButtonText"="219 220 222"
"GradientActiveTitle"="49 54 58"
"GradientInactiveTitle"="49 54 58"
"GrayText"="155 155 155"
"Hilight"="119 126 140"
"HilightText"="255 255 255"
"InactiveBorder"="49 54 58"
"InactiveTitle"="49 54 58"
"InactiveTitleText"="219 220 222"
"InfoText"="159 167 180"
"InfoWindow"="49 54 58"
"Menu"="49 54 58"
"MenuBar"="49 54 58"
"MenuHilight"="119 126 140"
"MenuText"="219 220 222"
"Scrollbar"="73 78 88"
"TitleText"="219 220 222"
"Window"="35 38 41"
"WindowFrame"="49 54 58"
"WindowText"="219 220 222"
EOT
wine regedit "$RESOURCESPATH/theme.reg" >/dev/null 2>&1
CHCK "Done"

INFO "Downloading Photoshop... "
[ -f "$RESOURCESPATH/cs6.tgz" ] || gddl "$RESOURCESPATH/cs6.tgz" "11XXyjIfLgHOxQBwqERdjHL4MzUmoxrAB"
CHCK "Done"

INFO "Extracting archive... "
tar -xzf "$RESOURCESPATH/cs6.tgz" -C "$PSPATH"
CHCK "Done"

if [ "$dlfonts" -ne 0 ]; then
    INFO "Downloading Microsoft fonts... "
    [ -f "$RESOURCESPATH/msfonts.tgz" ] || gddl "$RESOURCESPATH/msfonts.tgz" "1ZHlqqFsK2DVbEyCxynLp1_LBCe7yQB8o"
    CHCK "Done"

    INFO "Extracting fonts... "
    tar -xzf "$RESOURCESPATH/msfonts.tgz" -C "$FONTSPATH"
    CHCK "Done"
fi

INFO "Creating licensing identifier file... "
mkdir -p "$WINEPREFIX/dosdevices/c:/Program Files/Common Files/Adobe/PCF"
cat << 'EOT' > "$WINEPREFIX/dosdevices/c:/Program Files/Common Files/Adobe/PCF/{74EB3499-8B95-4B5C-96EB-7B342F3FD0C6}.Photoshop-CS6-Win-GM.xml"
<?xml version="1.0" encoding="utf-8"?>
<Configuration>
  <Payload adobeCode="{74EB3499-8B95-4B5C-96EB-7B342F3FD0C6}">
    <Data key="LicensingCode">Photoshop-CS6-Win-GM</Data>
  </Payload>
</Configuration>
EOT
CHCK "Done"

INFO "Creating launch script... "
cat << EOT > "$LAUNCHER"
#!/bin/sh

export WINEARCH=$WINEARCH
export WINEPREFIX="$WINEPREFIX"

case "\$1" in
    '--regedit')
        shift
        wine regedit \$@
        exit
        ;;
    '--winetricks')
        shift
        winetricks \$@
        exit
        ;;
    '--winecfg')
        wine winecfg
        exit
        ;;
    '--kill')
        wineserver -k
        exit
        ;;
    '-h'|'--help')
        echo \
'Usage:
  photoshop [OPTION...]
    or
  photoshop [FILE...]

Options:
  --regedit
      Run registry editor in the Photoshop prefix

  --winetricks <winetricks commands>
      Run winetricks in the Photoshop prefix

  --winecfg
      Run winecfg in the Photoshop prefix

  --kill
      Kill all wine and windows processes (dangerous)
'
        exit
        ;;
    *)
        if [ -n "\$1" ]; then
            case "\$1" in
                *.psd) format=Photoshop.Image.13 ;;
                *.psb) format=Photoshop.PSBFile ;;
                *.png) format=pngfile ;;
                *.jpg|*.jpeg|*.jpe) format=jpegfile ;;
                *.gif) format=giffile ;;
                *) echo "Unknown file."
                    photoshop -h
                    exit
                    ;;
            esac
            wine start /ProgIDOpen \$format "\$1" >/dev/null 2>&1
            exit
        fi
        ;;
esac

wine "X:/Photoshop.exe" >/dev/null 2>&1
EOT
sed -i "s|/home/$USER|\$HOME|g" "$LAUNCHER"
chmod +x "$LAUNCHER"
CHCK "Done"

INFO "Creating .desktop file... "
cat << 'EOT' > "$DESKTOPFILE"
[Desktop Entry]
Type=Application
Name=Adobe Photoshop CS6
Exec=photoshop %f
EOT
CHCK "Done"

INFO "Adding mime associations... "
if ! grep "[Default Applications]" "$HOME/.config/mimeapps.list" >/dev/null 2>&1; then
    echo "[Default Applications]" >> "$HOME/.config/mimeapps.list"
fi

if ! grep "image/vnd.adobe.photoshop=photoshop.desktop" "$HOME/.config/mimeapps.list" >/dev/null 2>&1; then
    sed -i '/\[Default\ Applications\]/a image/vnd.adobe.photoshop=photoshop.desktop' "$HOME/.config/mimeapps.list"
fi

for format in pngfile jpegfile giffile ; do
    cat << EOT > "$RESOURCESPATH/mime-$format.reg"
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\\$format\\shell\\open\\command]
@="\"Z:$PSPATH\\\\Photoshop.exe\" \"%1\""

[-HKEY_CLASSES_ROOT\\$format\\shell\\open\\ddeexec]

EOT
    sed -i 's|/|\\\\|g' "$RESOURCESPATH/mime-$format.reg"
    wine regedit "$RESOURCESPATH/mime-$format.reg" >/dev/null 2>&1
done; unset format
CHCK "Done"

INFO "Linking wine folders... "

# Unlink Wine folders from user folders
unlinkdir() { rm -rf "$1"; mkdir -p "$1"; }
for link in Desktop Documents Downloads Music Pictures Videos AppData/Roaming/Microsoft/Windows/Templates ; do
    unlinkdir "$WINEPREFIX/drive_c/users/$USER/$link"
done; unset link

# Link X: to Photoshop folder
ln -Tfs "$PSPATH" "$WINEPREFIX/dosdevices/x:"
CHCK "Done"

INFO "Cleaning up... "
rm -r "$RESOURCESPATH"
CHCK "Done"

CHCK "Installation finished!"
exit 0
