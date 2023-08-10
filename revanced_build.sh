#!/bin/bash
# Defining files
ints_url=$(curl -s https://api.github.com/repos/ReVanced/revanced-integrations/releases/latest | jq -r .assets[0].browser_download_url)
cli_url=$(curl -s https://api.github.com/repos/ReVanced/revanced-cli/releases/latest | jq -r .assets[0].browser_download_url)
patches_json_url=$(curl -s https://api.github.com/repos/ReVanced/revanced-patches/releases/latest | jq -r .assets[0].browser_download_url)
patches_jar_url=$(curl -s https://api.github.com/repos/ReVanced/revanced-patches/releases/latest | jq -r .assets[1].browser_download_url)

# Defining Versions
ints=$(curl -s https://api.github.com/repos/ReVanced/revanced-integrations/releases/latest | jq -r .assets[0].name)
cli=$(curl -s https://api.github.com/repos/ReVanced/revanced-cli/releases/latest | jq -r .assets[0].name)
patches=$(curl -s https://api.github.com/repos/ReVanced/revanced-patches/releases/latest | jq -r .assets[1].name)
yt_vers=$(curl -sL "$patches_json_url" | jq -r '.[0].compatiblePackages[].versions[-1]')
web_vers=$(echo $yt_vers | tr "." "-")

if [ ! -e $ints ] && [ ! -e $cli ] && [ ! -e $patches ];
then
    echo Downloading files:
    wget -nc -q $ints_url
    wget -nc -q $cli_url
    wget -nc -q $patches_jar_url
fi

# Downloading Youtube APK from apkmirror.com
if [ ! -e com.google.youtube.com_$yt_vers.apk ]
then
    echo -e "Recommended Youtube APK for this Release: \033[32;1m$yt_vers"
    link1=$(curl -sL "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$web_vers-release/youtube-$web_vers-2-android-apk-download/" --user-agent Firefox | grep forcebaseapk | cut -d \" -f 6)
    link2=$(curl -sL "https://www.apkmirror.com$link1" --user-agent Firefox | grep download.php? | cut -d \" -f 12 | sed 's/amp;//')
echo Download Youtube APK Version $yt_vers
    wget -nc --user-agent Firefox "https://www.apkmirror.com$link2" -O com.google.youtube.com_$yt_vers.apk
fi

# Building Revanced APK, if it does not exist
if [ -e "revanced_$yt_vers.apk" ]
then
    echo APK exists, not building
    exit 1
else
    read -p "Clean up afterwards? [y/N]" clean
    echo Building the Youtube Revanced APK:
    java -Djava.awt.headless=true  \
    -jar $cli \
    -a com.google.youtube.com_$yt_vers.apk \
    -b $patches \
    -m $ints \
    -i selected_patches_*.json \
    -o revanced_$yt_vers.apk
    if [ $clean == 'y|Y' ]
    then
    echo Cleaning up...
    rm $cli \
    $patches \
    $ints
    fi
    exit 0
fi
