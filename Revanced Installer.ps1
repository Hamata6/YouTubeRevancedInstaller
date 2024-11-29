Write-Host "Welcome to the automated YouTube Revanced Builder and Installer"
Write-Host "First, we need a YouTube apk file."
Write-Host "To know which version is supported by the patches, visit https://revanced.app/patches?pkg=com.google.android.youtube"
Write-Host "Note the version you see next to the bullseye emoji. Now download that YouTube apk version from internet (for example from APKMirror: https://www.apkmirror.com/apk/google-inc/youtube)"
Write-Host "Rename it to YouTube.apk and put it in the same folder as this script."
Read-Host "Press enter to continue when ready"

Write-Host "This script can automatically install the generated app to your device."
$autoinstall = Read-Host "Enable auto installation of the app [Y/n]?"

$devicecmd = ""
if ($autoinstall -ne "n") {
    Write-Host "To enable auto install, make sure you have adb.exe in the same folder as this script."
    Write-Host "adb can be downloaded from https://developer.android.com/studio/releases/platform-tools#downloads"
    Read-Host "Unzip it to the same folder as this script. Press enter to continue."
    
    Read-Host "Then, make sure your device is connected through USB and that USB debugging is turned ON. Leave your screen on. Press enter when ready."
    
    Write-Host "Looking for connected devices..."
    $devices = .\adb.exe devices
    $device = $devices.Split([Environment]::NewLine)[1].Split()[0].Trim()
    if ($device) {
        Write-Host "Found device with name: $device"
        $devicecmd = "--install $device"
        Read-Host "Now look at your device and grant access with the popup that is currently in view. Press enter when ready."
    } else {
        Read-Host "No connected device found. Try to unlock your device first. Then restart the script."
        exit
    }
}

$dodownload = Read-Host "Do you want to download the needed patch files [Y/n]?"

if ($dodownload -ne "n") {
    Write-Host "Now we are going to download the latest version of the needed resources. This might take a while, please be patient..."
    $json1 = Invoke-RestMethod -Uri "https://api.github.com/repos/revanced/revanced-patches/releases/latest"
    foreach ($j in $json1.assets) {
        $url = $j.browser_download_url
        if ($url.EndsWith(".rvp")) {
            Write-Host "Downloading from: $url"
            Invoke-WebRequest -Uri $url -OutFile revanced-patches.rvp
        }
    }

    $json2 = Invoke-RestMethod -Uri "https://api.github.com/repos/revanced/revanced-cli/releases/latest"
    foreach ($j in $json2.assets) {
        $url = $j.browser_download_url
        if ($url.EndsWith(".jar")) {
            Write-Host "Downloading from: $url"
            Invoke-WebRequest -Uri $url -OutFile revanced-cli-all.jar
        }
    }

#    $json3 = Invoke-RestMethod -Uri "https://api.github.com/repos/revanced/revanced-integrations/releases/latest"
#    foreach ($j in $json3.assets) {
#        $url = $j.browser_download_url
#        if ($url.EndsWith(".apk")) {
#            Write-Host "Downloading from: $url"
#            Invoke-WebRequest -Uri $url -OutFile revanced-integrations.apk
#        }
#    }
    Write-Host "Download completed"
}

Write-Host "Now we start compiling YouTube Revanced and if specified automatically install it on your device. Please be patient."

Invoke-Expression "java -jar revanced-cli-all.jar patch -p revanced-patches.rvp --out YouTubeMod.apk $devicecmd YouTube.apk"

Write-Host "Done! Check the above output for errors if any."
if ($autoinstall -ne "n") {
    Read-Host "If no errors above, you may disconnect your device now and launch the app. Have fun!"
} else {
    Read-Host "If no errors above, you may now transport the modded APK file to your device and install it. Have fun!"
}
