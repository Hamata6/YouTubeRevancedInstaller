Write-Host "Welcome to the automated YouTube Revanced Builder and Installer"
Write-Host "First, we need a YouTube apk file."
Write-Host "To know which version is supported by the patches, visit https://github.com/revanced/revanced-patches#-comgoogleandroidyoutube and click on Details."
Write-Host "Note the version you see in the 'Target Version' column. Now download that YouTube apk version from internet (for example from APKMirror: https://www.apkmirror.com/apk/google-inc/youtube/"
Read-Host "Press any key to continue when ready"

Read-Host "Then, make sure your device is connected through USB and that USB debugging is turned ON. (press any key to continue)"
Write-Host "Looking for connected devices..."
$devices = .\adb.exe devices
$device = $devices.Split([Environment]::NewLine)[1].Split()[0]
Write-Host "Found device with name: $device"

Write-Host "Now we are going to download the latest version of the needed resources."
$json1 = Invoke-RestMethod -Uri "https://api.github.com/repos/revanced/revanced-patches/releases/latest"
foreach ($j in $json1.assets) {
    $url = $j.browser_download_url
    if ($url.Contains(".jar")) {
        Write-Host "Downloading from: $url"
        Invoke-WebRequest -Uri $url -OutFile revanced-patches.jar
    }
}

$json2 = Invoke-RestMethod -Uri "https://api.github.com/repos/revanced/revanced-cli/releases/latest"
foreach ($j in $json2.assets) {
    $url = $j.browser_download_url
    if ($url.Contains(".jar")) {
        Write-Host "Downloading from: $url"
        Invoke-WebRequest -Uri $url -OutFile revanced-cli-all.jar
    }
}

$json3 = Invoke-RestMethod -Uri "https://api.github.com/repos/revanced/revanced-integrations/releases/latest"
foreach ($j in $json3.assets) {
    $url = $j.browser_download_url
    if ($url.Contains(".apk")) {
        Write-Host "Downloading from: $url"
        Invoke-WebRequest -Uri $url -OutFile app-release-unsigned.apk
    }
}

Write-Host "Download completed. Now we start compiling YouTube Revanced and automatically install it on your device. Please be patient."
java -jar revanced-cli-all.jar -a YouTube.apk -c -d $device -o revanced.apk -b revanced-patches.jar -m app-release-unsigned.apk

Read-Host "Done! Check the above output for errors if any. Otherwise, you may disconnect your device now and launch the app. Have fun!"