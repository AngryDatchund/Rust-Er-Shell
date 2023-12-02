# URL
$urlSteamCmd = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$urlOxide = "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust.zip"
$urlCarbon = "https://github.com/CarbonCommunity/Carbon.Core/releases/latest/download/Carbon.Windows.Release.zip"
$urlTestMap = "https://github.com/AngryDatchund/Rust-Er-Shell/raw/main/Resources/RES-TestMap.map"

# Folders
$pathFolderRoot = $PSScriptRoot;
$pathFolderServer = "$pathFolderRoot\RustServer"
$pathFolderAppDataLocal = "$env:LOCALAPPDATA\RustErShell"
$pathFolderSteamCmd = "$pathFolderAppDataLocal\SteamCMD"
$pathFolderCarbon = "$pathFolderServer\carbon"
$pathFolderServerCfg = "$pathFolderServer\server\example\cfg"

# Files
$pathFileSteamCmd = "$pathFolderSteamCmd\steamcmd.exe"
$pathFileTemp = "$pathFolderAppDataLocal\Temp.zip"
$pathFileStartBat = "$pathFolderRoot\Example.bat"
$pathFileServerCfg = "$pathFolderServerCfg\server.cfg"

# Functions
function InstallSteamCMD 
{
    if (Test-Path($pathFileSteamCmd))
    {
        Write-Host "[SteamCMD] SteamCMD is already installed"
    }
    else 
    {
        Write-Host "[SteamCMD] Installing SteamCMD..."
        DownloadAndExtract -url $urlSteamCmd -extractPath $pathFolderSteamCmd
        Write-Host "[SteamCMD] SteamCMD was installed!"
    }
}

function UpdateServer 
{
    Write-Host "[SERVER] Updating server..."
    Start-Process $pathFileSteamCmd -ArgumentList "+force_install_dir $pathFolderServer +login anonymous +app_update 258550 -validate +quit" -Wait -NoNewWindow
    Write-Host "[SERVER] Server was updated!"
}

function InstallCarbon 
{
    if (Test-Path ($pathFolderCarbon))
    {
        Write-Host "[CARBON] Carbon is already installed"
    }
    else
    {
        Write-Host "[CARBON] Installing Carbon..."
        DownloadAndExtract -url $urlCarbon -extractPath $pathFolderServer
        Write-Host "[CARBON] Carbon was installed!"
    }
}

function InstallOxide
{
    Write-Host "[OXIDE] Installing Oxide..."
    DownloadAndExtract -url $urlOxide -extractPath $pathFolderServer
    Write-Host "[OXIDE] Oxide was installed!"
}

function CreateExamples
{
    Write-Host "Creating example bat and cfg files"

    # Create Example Bat
    if (!(Test-Path $pathFileStartBat))
    {
        $null = New-Item -Path $pathFileStartBat -Value "cd RustServer`n:start`nRustDedicated.exe -batchmode -nographics -logFile Log.txt +server.identity ""example"" +oxide.directory ""server/example/oxide/""`ntimeout /t 10 /nobreak`ngoto start"
    }
   
    # Create Example server.cfg
    if (!(Test-Path $pathFileServerCfg))
    {
        if (!(Test-Path $pathFolderServerCfg))
        {
            $null = New-Item -Path $pathFolderServerCfg -ItemType "directory"
        }
        
        $null = New-Item -Path $pathFileServerCfg -Value "server.worldsize 1500`nserver.maxplayers 5`nfps.limit 256`nbaseboat.generate_paths 0`nantihack.terrain_kill false`nantihack.terrain_protection false`ncensorplayerlist true`nserver.secure false`nserver.levelurl ""$urlTestMap"""
    }
}

# Utils
function DownloadAndExtract 
{
    param ($url, $extractPath)

    if (Test-Path $pathFileTemp)
    {
        Remove-Item $pathFileTemp
    }
   
    Invoke-WebRequest $url -OutFile $pathFileTemp
    Expand-Archive $pathFileTemp -DestinationPath $extractPath -Force
    
    if (Test-Path $pathFileTemp)
    {
        Remove-Item $pathFileTemp
    }
}

function PrintOptions
{
    Write-Host "Select option:"
    Write-Host "1 - Install/Update Server"
    Write-Host "2 - Install Oxide"
    Write-Host "3 - Install Carbon"
    Write-Host "-------------------------"
    Write-Host "4 - Add Example.bat and server.cfg"
    Write-Host "-------------------------"
    Write-Host "Use numbers for multiple selection: 12 (Server + Oxide), 124 (Server + Oxide + Examples), etc"
}

function CheckOptions 
{
    param ([string] $option)

    if ($option.Contains("4"))
    {
        CreateExamples
    }

    if ($option.Contains("1"))
    {
        InstallSteamCMD
        UpdateServer
    }

    if ($option.Contains("2"))
    {
        InstallOxide
    }

    if ($option.Contains("3"))
    {
        InstallCarbon
    }

    Write-Host $option.GetType()
}

# Load
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

    $host.ui.RawUI.WindowTitle = "RustErShell v3 ($pathFolderServer)"

    # Create Server Directory
    if (!(Test-Path -Path $pathFolderServer -PathType Container))
    {
        $null = New-Item -Path $pathFolderServer -ItemType "directory"
    }
    
    PrintOptions
    $option = Read-Host "Option"
    CheckOptions -option $option.ToString()
}

# Start
Load