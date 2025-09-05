###################################################
################Script Configuration###############
###################################################
$intellij_installer = "intellij-2025.1.3.exe"
$intellij_installer_config = "Intellij.config"
$intellij_settings = "Intellij.xml"
$intellij_config_folder = "$($env:appdata)\JetBrains\IdeaIC2025.1"

$gitkraken_installer = "GitKrakenSetup.exe"

$wpilib_directory = "C:\Users\Public\wpilib\2025"

$gametools_installer = "game-tools_25.0.1.iso"
$gametools_config = "gameToolsconfig.ini"
###################################################
###################################################
###################################################

function Prompt-WithDefault {
    param (
        [string]$Message,
        [string]$DefaultValue
    )

    $response = Read-Host "$Message (default: $DefaultValue)"
    if ([string]::IsNullOrWhiteSpace($response)) {
        $response = $DefaultValue
    }

    $response = $response.ToLower()
    return ($response -eq "y" -or $response -eq "yes")
}

function RelativePath {
    $ScriptDir = $PSScriptRoot
    $RelativePath = Join-Path $ScriptDir $args[0]
	return $RelativePath
}

# info
Write-Host "Step 0/6"
Write-Host "This script will setup your computer for robot programming and install the folowing applications:"
Write-Host "Intellij"
Write-Host "Java"
Write-Host "GitKraken"
Write-Host "FRC Game Tools"
Write-Host "WPILib"

Write-Host "Please close all other apps, its ok to leave a web browser (Google Chrome) open"
Write-Host "When asked a yes or no question type 'Y' or 'N' and then press enter. If you push enter without entering a value, the default value (shown in parenthisis) will be used"
Write-Host "If you are just getting started, the default values are what you want"
Write-Host "As the installer progresses, other windows will popup, this screen will always tell you what to buttons to push in the other windows"


Do {
	$ready = Prompt-WithDefault -Message "Have you closed other apps?" -DefaultValue "n"
} While (!$ready)

Clear-Host


# Install IntelliJ

Write-Host "Step 1/5"
$intellij = Prompt-WithDefault -Message "Do you want to install IntelliJ?" -DefaultValue "y"

if($intellij) {
	#TODO: Check already installed
	#Run installer
	$intellijExe = RelativePath $intellij_installer
	$intellijConfig = RelativePath $intellij_installer_config
	$intellijSettings = RelativePath $intellij_settings
	Write-Host "Installing IntelliJ, this may take a while....."
	Start-Process $intellijExe -ArgumentLis "/S /C=$($intellijConfig)" -Wait
	Write-Host "Setting up IntelliJ...."
    if(!(Test-Path -Path $intellij_config_folder)) {
	    New-Item -name "codestyles" -ItemType "Directory" -Path "$($env:appdata)\JetBrains\IdeaIC2025.1"
    }
	Copy-Item -Path $intellijSettings -Destination "$($intellij_config_folder)\codestyles\Default.xml"
	#error handling
}

Clear-Host

# install gitkraken

Write-Host "Step 2/5"
$git = Prompt-WithDefault -Message "Do you want to install GitKraken?" -DefaultValue "y"
if ($git) {
	#install gitkraken
	$gitExe = RelativePath $gitkraken_installer
	Start-Process $gitExe -Wait
	#The gitkraken installer launches another executable, so the "-Wait" doesn't really work
	#This was the easiest solution
	Read-Host -Prompt "Press Enter to continue once installation is complete"
}

Clear-Host

# install wpilib

Write-Host "Step 3/5"
$wpilib = Prompt-WithDefault -Message "Do you want to install WPILib?" -DefaultValue "y"
if($wpilib) {
	Do {
	Write-Host "A window will open soon, click Start"
	Write-Host "Install Everything for just your user"
	Write-Host "Press skip and don't use VSCode (it won't like it, but we don't use it)"
	$wpilibConfirm = Prompt-WithDefault -Message "Did you read this? ^^^" -DefaultValue "n"
		
	} While (!$wpilibConfirm)
	#Install wpilib
	Write-Host "Installing WPILib"
	$wpiPath = RelativePath "WPILib\WPILibInstaller.exe"
	Unblock-File -Path $wpiPath
	Start-Process $wpiPath -Wait

	Write-Host "Setting up java symlink"
	New-Item -Path "C:\Program Files\" -Name "Java" -ItemType "Directory"
	New-Item -Path "C:\Program Files\Java\wpilib-jdk" -ItemType SymbolicLink -Target "$($wpilib_directory)\jdk"

	Write-Host "Setting up java environment variables"
	$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
	$targetPath = "%JAVA_HOME%\bin"
	$pathList = $currentPath -split ";" | ForEach-Object { $_.Trim().ToLower() }

	if (-not ($pathList -contains $targetPath.ToLower())) {
	    $newPath = "$currentPath;$targetPath"
    	    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
     	    Write-Host "Added $targetPath to system PATH"
	} else {
	    Write-Host "Found JAVA_HOME in PATH already, skipping..."
	}

	[System.Environment]::SetEnvironmentVariable("JAVA_HOME", "C:\Program Files\Java\wpilib-jdk", "Machine");
}

Clear-Host

# setup build scripts

Write-Host "4/5"
$buildScripts = Prompt-WithDefault -Message "Do you want to setup build scripts (gg/gb/gs)?" -DefaultValue "y"
if ($buildScripts) {
	#check if build scripts already there
	#add build scripts

	$currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
	$targetPath = "buildscripts"
	$pathList = $currentPath -split ";" | ForEach-Object { $_.Trim().ToLower() }

	if (-not ($pathList -contains $targetPath.ToLower())) {
	    $newPath = "$currentPath;$targetPath"
    	    [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
     	    Write-Host "Added $targetPath to system PATH"
	} else {
	    Write-Host "Found buildscripts in PATH already, skipping..."
	}	
}

Clear-Host

# install game tools
Write-Host "Step 5/5"
$gameTools = Prompt-WithDefault -Message "Do you want to install FRC Game Tools?" -DefaultValue "y"
if($gameTools) {
	#Install game tools
	$gameToolsIsoPath = RelativePath $gametools_installer
	$gameToolsDiskImage = Mount-DiskImage -ImagePath $gameToolsIsoPath -PassThru
	$gameToolsVolume = Get-Volume -DiskImage $gameToolsDiskImage
	$gameToolsDriveLetter = $gameToolsVolume.DriveLetter
	$gameToolsConfig = RelativePath $gametools_config

	Write-Host "Configuring Driver Station"
	if(!(Test-Path -Path "C:\Users\Public\Documents\FRC")){
		New-Item -Path "C:\Users\Public\Documents\" -Name "FRC" -ItemType "Directory"
	}
	Copy-Item -Path $gameToolsConfig -Destination "C:\Users\Public\Documents\FRC\FRC DS Data Storage.ini"
	Write-Host "Done Configuring Driver Station"

	Write-Host "Game Tools ISO Mounted"
	Write-Host "Installing Game Tools, please follow directions on the popup window. This may take awhile......"
	Start-Process "$($gameToolsDriveLetter):\Install.exe" -Wait
	Dismount-DiskImage -ImagePath $gameToolsIsoPath
}

Clear-Host

Read-Host "Push Enter to continue....."

# Show ToDo list:
# - computer health check
# - sign into gitkraken
# - reboot computer
# - errors detected?
