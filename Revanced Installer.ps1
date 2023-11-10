Write-Host "Welcome to the automated YouTube Revanced Builder and Installer"
Write-Host "First, we need a YouTube apk file."
Write-Host "To know which version is supported by the patches, visit https://revanced.app/patches?pkg=com.google.android.youtube"
Write-Host "Note the version you see next to the bullseye emoji. Now download that YouTube apk version from internet (for example from APKMirror: https://www.apkmirror.com/apk/google-inc/youtube)"
Write-Host "Rename it to YouTube.apk and put it in the same folder as this script."
Read-Host "Press enter to continue when ready"

Write-Host "This script can automatically install the generated app to your device."
$autoinstall = Read-Host "Enable auto installation of the app [y/n]?"
$devicecmd = ""
if ($autoinstall -eq "y") {
    Write-Host "To enable auto install, make sure you have adb.exe in the same folder as this script."
    Write-Host "adb can be downloaded from https://developer.android.com/studio/releases/platform-tools#downloads"
    Read-Host "Unzip it to the same folder as this script. Press enter to continue."
    Read-Host "Then, make sure your device is connected through USB and that USB debugging is turned ON. Press enter when ready."
    Write-Host "Looking for connected devices..."
    $devices = .\adb.exe devices
    $device = $devices.Split([Environment]::NewLine)[1].Split()[0].Trim()
    if ($device) {
	    Write-Host "Found device with name: $device"
        $devicecmd = "--device-serial $device"
		Read-Host "Now look at your device and grant access with the popup that is currently in view. Press enter when ready"
    } else {
        Read-Host "No connected device found. Try to unlock your device first."
		exit
    }
}

$skipdownload = Read-Host "Do you want to skip downloading the needed files [y/n]?"
if ($skipdownload -eq "n") {
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
	Write-Host "Download completed"
}

Write-Host "Now we start compiling YouTube Revanced and if specified automatically install it on your device. Please be patient."
java -jar revanced-cli-all.jar patch --patch-bundle revanced-patches.jar --out YouTubeMod.apk $($devicecmd) --merge app-release-unsigned.apk YouTube.apk

Read-Host "Done! Check the above output for errors if any. Otherwise, you may disconnect your device now and launch the app. Have fun!"
