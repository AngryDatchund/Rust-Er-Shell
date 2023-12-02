# OTHER
$pathServer = "$PSScriptRoot\RustServer"
$pathAppDataLocal = "$env:LOCALAPPDATA\RustErShell\"
$pathTempFile = "$pathAppDataLocal\Temp.zip"

# STEAM CMD
$urlSteamCmd = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$pathSteamCmd = "$pathAppDataLocal\SteamCMD"
$pathSteamCmdExe = "$pathSteamCmd\steamcmd.exe"

# OXIDE
$urlOxide = "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust.zip"

# CARBON
$urlCarbon = "https://github.com/CarbonCommunity/Carbon.Core/releases/latest/download/Carbon.Windows.Release.zip"
$pathCarbon = "$pathServer\carbon"

function InstallSteamCMD 
{
    if (Test-Path($pathSteamCmdExe))
    {
        Write-Host "[SteamCMD] SteamCMD is already installed"
    }
    else 
    {
        Write-Host "[SteamCMD] Installing SteamCMD..."
        DownloadAndExtract -url $urlSteamCmd -extractPath $pathSteamCmd
        Write-Host "[SteamCMD] SteamCMD was installed!"
    }
}

function InstallCarbon 
{
    if (Test-Path ($pathCarbon))
    {
        Write-Host "[CARBON] Carbon is already installed"
    }
    else
    {
        Write-Host "[CARBON] Installing Carbon..."
        DownloadAndExtract -url $urlCarbon -extractPath $pathServer
        Write-Host "[CARBON] Carbon was installed!"
    }
}

function InstallOxide
{
    Write-Host "[OXIDE] Installing Oxide..."
    DownloadAndExtract -url $urlOxide -extractPath $pathServer
    Write-Host "[OXIDE] Oxide was installed!"
}

function DownloadAndExtract 
{
    param ($url, $extractPath)

    if (Test-Path $pathTempFile)
    {
        Remove-Item $pathTempFile
    }
   
    Invoke-WebRequest $url -OutFile $pathTempFile
    Expand-Archive $pathTempFile -DestinationPath $extractPath -Force
    
    if (Test-Path $pathTempFile)
    {
        Remove-Item $pathTempFile
    }
}

function UpdateServer 
{
    Write-Host "[SERVER] Updating server..."
    Start-Process $pathSteamCmdExe -ArgumentList "+force_install_dir $pathServer +login anonymous +app_update 258550 -validate +quit" -Wait -NoNewWindow
    Write-Host "[SERVER] Server was updated!"
}

function PrintOptions
{
    Write-Host "Select option:"
    Write-Host "1 - Install/Update Server"
    Write-Host "2 - Install Oxide"
    Write-Host "3 - Install Carbon"
    Write-Host "-------------------------"
    Write-Host "12 - Server + Oxide"
    Write-Host "13 - Server + Carbon"
}

function CheckOptions 
{
    param ($option)

    switch($option)
    {
        1
        {
            InstallSteamCMD
            UpdateServer
        }
        2
        {
            InstallSteamCMD
            InstallOxide
        }
        3
        {
            InstallSteamCMD
            InstallCarbon
        }
        12
        {
            InstallSteamCMD
            UpdateServer
            InstallOxide
        }
        13
        {
            InstallSteamCMD
            UpdateServer
            InstallCarbon
        }
        default
        {
            Write-Host "Wrong option - '{$option}'"
        }
    }
}

function Load 
{
    Write-Host "====================================================================================================================="
    Write-Host "     ########  ##     ##  ######  ######## ######## ########         ######  ##     ## ######## ##       ##       "
    Write-Host "     ##     ## ##     ## ##    ##    ##    ##       ##     ##       ##    ## ##     ## ##       ##       ##       "
    Write-Host "     ##     ## ##     ## ##          ##    ##       ##     ##       ##       ##     ## ##       ##       ##       "
    Write-Host "     ########  ##     ##  ######     ##    ######   ########         ######  ######### ######   ##       ##       "
    Write-Host "     ##   ##   ##     ##       ##    ##    ##       ##   ##               ## ##     ## ##       ##       ##       "
    Write-Host "     ##    ##  ##     ## ##    ##    ##    ##       ##    ##        ##    ## ##     ## ##       ##       ##       "
    Write-Host "     ##     ##  #######   ######     ##    ######## ##     ##        ######  ##     ## ######## ######## ######## "
    Write-Host "====================================================================================================================="

    $host.ui.RawUI.WindowTitle = "RustErShell v2 ($pathServer)"
    #Write-Host "Launching for '$pathServer'"

    if (!(Test-Path -Path $pathServer -PathType Container))
    {
        $null = New-Item -Path $pathServer -ItemType "directory"
    }
    
    PrintOptions
    $option = Read-Host "Option"
    CheckOptions -option $option
}

Load