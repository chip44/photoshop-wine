# <p align="center">Adobe Photoshop CS6 installer for Linux</p>

This is a shell script for an automatic Photoshop installation.



## Features

- Fully automatic install - no user interaction
- Can open psd and image files
- No Adobe Bridge, Link, or any similar bullshit
- Only creates the necessary stuff:
    - Wine prefix folder
    - Separate folder for Photoshop
    - Launch script
    - .desktop file and mime associations

If you have any issues/suggestions, feel free to open an issue here or contact me via Discord (**chip#4111**).



## Some notes
- This was tested on Arch Linux, however I see no reason for it to not work on other distros as long as you meet the requirements.
- Please keep in mind that the Photoshop files are not official - they were taken from ChingLiu's torrent on [1337x.to](https://1337x.to).\
  ChingLiu only provided the setup, I simply installed it, applied the crack and zipped it for an easier installation.\
  You can do the same yourself if you don't trust this.



## Requirements

- A POSIX compliant shell

- Dependencies:
    - `wine`
    - `coreutils`
    - `tar`
    - `curl`

-  About `1GB` of free space in `~/`
    - Choosing a different directory isn't supported yet but you can change it manually by editing the `$BASEDIR` variable inside the script.

- A functioning internet connection to download the components

- Make sure `~/.local/bin/` is in your `$PATH` (some distros don't set it by default)



## Installation

Clone this repository to your desired location:
```
$ git clone https://github.com/chip44/photoshop-wine.git
$ cd photoshop-wine
```

Run the installation script:
```
$ chmod +x install.sh
$ ./install.sh
```

You can freely delete this folder after the installation as it's no longer needed.



## Usage

#### Run Photoshop:
```
$ photoshop
```

#### Open a file with Photoshop:
```
$ photoshop file.psd
```
`xdg-open` should also work:
```
$ xdg-open file.psd
```
- Opening png/jpg/jpeg files works too

#### Display all available options:
```
$ photoshop --help
```



## Uninstall

To completely remove Photoshop from your system, simply delete the following files/folders:
- `~/.local/share/photoshop-wine/` (or your own installation folder, if you changed it)
- `~/.local/bin/photoshop`
- `~/.local/share/applications/photoshop.desktop`

Also delete this line from `~/.config/mimeapps.list`:
- `image/vnd.adobe.photoshop=photoshop.desktop`



## Troubleshooting

### Every time I move it registers only the previous movement!
- Go to *Edit > Preferences > Performance* and uncheck *'Use Graphic Processor'*.
- This will disable hardware acceleration, but at least the program is now usable.

### Photoshop crashes when a menu is opened!
- Don't use `wine-staging`.
- This issue could be already fixed after writing this, so try updating the package first.

### Tooltips don't disappear from the screen until the program closes!
- This is a bug with Wine, a workaround is to disable tooltips by going to *Edit > Preferences > Interface* and unchecking *'Show Tool Tips'*.

### "Could not initialize Photoshop because of a program error" / "Something prevented the text engine from being initialized"
- Install Microsoft fonts.
- If you are on Arch, the easiest way is to install [ttf-ms-win10-auto](https://aur.archlinux.org/packages/ttf-ms-win10-auto) from the AUR.\
  Otherwise, you can extract the fonts manually from a Windows ISO as explained [here](https://wiki.archlinux.org/title/Microsoft_fonts#Extracting_fonts_from_a_Windows_ISO), and place them in `~/.local/share/fonts/` (or `/usr/share/fonts/` for system-wide).



## TODO

- Add icon ~*(perhaps make it a choice?)*~

