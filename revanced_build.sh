#!/bin/bash

# Check Ratelimit
rt=$(curl -s https://api.github.com/rate_limit | jq .rate.remaining)
# Defining files
cli_url=$(curl -s https://api.github.com/repos/ReVanced/revanced-cli/releases/latest | jq -r .assets[0].browser_download_url)
patches_json_url=$(curl -s https://api.github.com/repos/ReVanced/revanced-patches/releases/latest | jq -r .assets[0].browser_download_url)
patches_rvp_url=$(curl -s https://api.github.com/repos/ReVanced/revanced-patches/releases/latest | jq -r .assets[0].browser_download_url)

if [ $rt -ge "8" ]
then
    echo "Downloading files:"
    wget -nc -q $cli_url
    wget -nc -q $patches_rvp_url
    echo "Done!"
else
    echo "API limit exceeded, wait for a few minutes"
    exit 1
fi

# Defining Versions
cli=$(curl -s https://api.github.com/repos/ReVanced/revanced-cli/releases/latest | jq -r .assets[0].name)
patches=$(curl -s https://api.github.com/repos/ReVanced/revanced-patches/releases/latest | jq -r .assets[0].name)
yt_vers=$(java -jar $cli list-versions $patches -f com.google.android.youtube | tr "\tb" "\n" | tr " " "\n" | grep ^[0-9] | sort | tail -1)
web_vers=$(echo $yt_vers | tr "." "-")

# Downloading Youtube APK from apkmirror.com
if [ ! -e com.google.youtube.com_$yt_vers.apk ]
then
    echo -e "Recommended Youtube APK for this Release: \033[32;1m$yt_vers\033[0m"
    link1=$(curl --user-agent Firefox -sL "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$web_vers-release/youtube-$web_vers-2-android-apk-download/" | grep forcebaseapk | cut -d \" -f 6)
    link2=$(curl --user-agent Firefox -sL "https://www.apkmirror.com$link1" | grep download.php? | cut -d \" -f 14)
echo Download Youtube APK Version $yt_vers
    wget -nc --user-agent Firefox "https://www.apkmirror.com$link2" -O com.google.youtube.com_$yt_vers.apk
fi

# Building Revanced APK, if it does not exist
if [ -e "revanced_$yt_vers.apk" ]
then
    echo "APK exists, not building"
    exit 2
else
    echo "Building the Youtube Revanced APK:"
    java -Djava.awt.headless=true \
    -jar $cli \
    patch com.google.youtube.com_$yt_vers.apk \
    -p $patches \
    -o revanced_$yt_vers.apk
    echo "Done!"
    exit 0
fi
