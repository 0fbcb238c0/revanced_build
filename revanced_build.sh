#!/bin/bash
# Downloading Revanced Integrations
    int_vers=$(curl -sL https://github.com/ReVanced/revanced-integrations | grep tag/ | cut -d \" -f 8 | cut -d \/ -f 6 | tr -d v)
echo Current Integrations: v$int_vers
echo Downloading Integrations APK:
    wget -nc -q https://github.com/ReVanced/revanced-integrations/releases/download/v$int_vers/revanced-integrations-$int_vers.apk
echo Done!
# Downloading Revanced-CLI
    cli_vers=$(curl -sL https://github.com/revanced/revanced-cli | grep tag/ | cut -d \" -f 8 | cut -d \/ -f 6 | tr -d v)
echo Current Revanced-CLI: v$cli_vers
echo Downloading Revanced-CLI JAR:
    wget -nc -q https://github.com/ReVanced/revanced-cli/releases/download/v$cli_vers/revanced-cli-$cli_vers-all.jar
echo Done!
# Downloading Patches
    patches_vers=$(curl -sL https://github.com/revanced/revanced-patches | grep tag/ | cut -d \" -f 8 | cut -d \/ -f 6 | tr -d v)
echo Current Revanced patches: v$patches_vers
echo Downloading Revanced patches JAR:
    wget -nc -q https://github.com/ReVanced/revanced-patches/releases/download/v$patches_vers/revanced-patches-$patches_vers.jar
echo Done!
echo Recommended Youtube APK for this Release:
    yt_vers=$(curl -sL https://github.com/ReVanced/revanced-patches/releases/download/v$patches_vers/patches.json | json_reformat | grep '"com.google.android.youtube"' -B 1 -A 10 | jq -r '.versions[]' 2> /dev/null | grep [0-9] | tail -1)
printf "\033[32m$yt_vers\033[0m\n"
echo Getting Download link for APK from APKmirror.com if automatic download fails:
    web_vers=$(echo $yt_vers | tr "." "-")
echo https://www.apkmirror.com/apk/google-inc/youtube/youtube-$web_vers-release/
# Getting Link of APK
    link1=$(curl -sL "https://www.apkmirror.com/apk/google-inc/youtube/youtube-$web_vers-release/youtube-$web_vers-2-android-apk-download/" --user-agent Firefox | grep forcebaseapk | cut -d \" -f 6)
    link2=$(curl -sL "https://www.apkmirror.com$link1" --user-agent Firefox | grep download.php? | cut -d \" -f 12 | sed 's/amp;//')
echo Download Youtube APK Version $yt_vers
#echo "https://www.apkmirror.com$link2"
    wget -nc --user-agent Firefox "https://www.apkmirror.com$link2" -O com.google.youtube.com_$yt_vers.apk
if [ -e "revanced_$yt_vers.apk" ]
then
    echo APK exists, not building
    exit 1
else
    echo Building the Youtube Revanced APK:
    java -Djava.awt.headless=true -jar revanced-cli-$cli_vers-all.jar -a com.google.youtube.com_$yt_vers.apk -b revanced-patches-$patches_vers.jar -m revanced-integrations-$int_vers.apk -i selected_patches_*.json -o revanced_$yt_vers.apk
    exit 0
fi
