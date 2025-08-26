![Gear it Forward Logo](2338Logo.png)

# FRC Team 2338: Gear It Forward

# Automated Computer Setup

## About the Script

This is a powershell script that automatically installs and configures all the software required for programmers on Team 2338. Here is a comprehensive list of all script functions:

-   Install Intellij IDEA 2025.1.3
-   Configure Intellij (No wildcard imports)
-   Install GitKraken
-   Install WPILib 2025.3.2
-   Setup WPILib's packaged JDK 17 to be used (PATH and JAVA_HOME)
-   Setup our buildscripts (shortcuts for "gradlew" commands)
-   Install FRC Game Tools 2025 Patch 1
-   Preconfigure Driver Station with our team number and dashboard (Elastic)

## Using the Script

**Important**: This script is only compatible with windows systems.

You must restart your computer after the script is complete, please save all work and close all apps before running the script.

1. Download the required file from [Google Drive](https://drive.google.com/file/d/1h1omZl-5aztTXE5eee9PJXVZr0BpG1i4/view?usp=sharing)
2. Extract the zip file
    1. Right click the file and click "Extract All"
3. Double click the file named "RUN ME"
4. Allow Administrator Permissions
5. Follow the prompts on the script.
   **Read all the instructions that it prints, they are important and tell you what you need to do to successfully install the software**

## Maintaining the Script and more advanced explanation

I have not tested this script ever to update computers, as that is much easier to do manually than starting from scratch. I would highly recommend testing extensivly before using it to update existing installations.

It is important to refrain from uploading installers to Github. Once you have the script working, zip it and distribute it via Google Drive (it will be too big to upload with github releases). Push only the script file and the configuration files. I also chose to hide all the files except for "RUN ME.bat" (right click, properties, check "hidden").

### Step 1 - IntelliJ

To increment the version, download the new exe installer, update the file name and config folder at the top of the `install.ps1` file, and update the version in the README

IntelliJ is installed silently, so the user is not presented with any options during the install. These options are configured in the `intellij_installer_config` file. [Reference](https://www.jetbrains.com/help/idea/installation-guide.html#silent)

The `intellij_settings` file is used to define code style settings. To create this file, I created a new installtion of intellij in a vm, then changed the settings I wanted to include in the file. Then I copied the file from the configuration directory. [Reference](https://www.jetbrains.com/help/idea/directories-used-by-the-ide-to-store-settings-caches-plugins-and-logs.html)

### Step 2 - GitKraken

This is the simplest of the installations, all it does is run the installer. To increment the version simply replace the setup file with the updated one and change the filename in `install.ps1` if necessary.

### Step 3 - WPILib

To increment the version, replace the WPILib iso, update the filename, and update the installation directory (usually just changing the year). The script assumes that the executable is called `WPILibInstaller.exe` and is located at the root of the ISO.

This step has several parts. First we have to mount the ISO, then obtain its drive letter. Once we have that, we can run the installer. Once the installer is complete, we can setup the java install. The script assumes that the WPILib java install is in a folder called `java` at the root of the installation directory.

The WPILib Java install is used by creating a symlink into the program files. The PATH is based off of JAVA_HOME which is based off of the symlink. I decided to create the symlink instead of pointing the `JAVA_HOME` directly to the wpilib installation folder to aid someone unfamilar with the script in troubleshooting in the future.

### Step 4 - buildscripts

Buildscripts are a set of shortcuts for `./gradlew build`, `./gradlew deploy`, and `./gradlew simulateJava`. The setup consists of checking the path for `buildscripts` and adding it if it's not found. If you want to change the string added to the path, change the `targetPath` variable.

### Step 5 - FRC Game Tools

This installation is very similar to the WPILib one. To increment the version, replace the iso file, and update the name in `install.ps1`. The script expects the installer to be named `Install.exe` and located at the root of the ISO

This step begins with configuring Driver Station because the installer restarts when it is complete. The configuration is done by creating the configuration directory and then copying the file to it. This file is detailed [here](https://frcdocs.wpi.edu/en/2024/docs/software/driverstation/manually-setting-the-driver-station-to-start-custom-dashboard.html).

After the file is copied, the ISO is Mounted, and the installer is run. The script does dismount the ISO after the install is completed, but the user should have clicked "Restart Now" at the end of the installer, so theoretically that part never runs.

The 2026 season will be the last that Driver Station will be used. Hopefully there is enough example code to adapt to the new limelight controller software when it comes out.

