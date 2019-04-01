<#
    Author: Justin Tadlock
    Date: 9/19/2018
    Description:
        A script used to set up a client machine to be able to create local mini-dump files for 
        development to support OPS teams when applications crash.

    Usage:
        On the client machine, open cmd as an admin and run the following commands:
            cd "PathToTheFolderThatContainsThisScript"
            powershell -executionpolicy bypass -command ".\LocalDumpPrep.ps1"
#>


#Create the registry key that allows a system to create local dump files.
#=====================================================================================
$RegKey = "HKLM:\SOFTWARE\Microsoft\Windows\Windows Error Reporting\LocalDumps"

if( (Test-Path -Path "$RegKey") -eq $false ) {
    New-Item -Path "$RegKey" | Out-Null
}
Set-ItemProperty -Path "$RegKey" -Name "DumpType" -Value 2 -Force
#=====================================================================================


#Create the CrashDumps folder if it doesn't exist
#=====================================================================================
$CrashDumpLocation = "$($env:USERPROFILE)\AppData\Local\CrashDumps"
if( (Test-Path -Path $CrashDumpLocation) -eq $false) {
    New-Item -Path $CrashDumpLocation -ItemType Directory -Force | Out-Null
}
#=====================================================================================


#Create a shortcut (if it doesn't exist) on the desktop for quick access to dump files
#=====================================================================================
$ShortcutLocation = "$($env:USERPROFILE)\Desktop\CrashDumpFolder.lnk"

if( (Test-Path -Path $ShortcutLocation) ) {
    Remove-Item -Path $ShortcutLocation -Force
}

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutLocation)
$Shortcut.TargetPath = $CrashDumpLocation
$Shortcut.IconLocation = "imageres.dll,0"
$Shortcut.Description = "A shortcut for quick access to the CrashDumps folder to send to Development for debugging and support."
$Shortcut.WorkingDirectory = $(Split-Path -Path $ShortcutLocation)
$Shortcut.Save()
#=====================================================================================