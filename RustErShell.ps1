# URL
$urlSteamCmd = "https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip"
$urlOxide = "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust.zip"
$urlCarbon = "https://github.com/CarbonCommunity/Carbon.Core/releases/latest/download/Carbon.Windows.Release.zip"
$urlTestMap = "https://github.com/AngryDatchund/Rust-Er-Shell/raw/main/Resources/RES-TestMap.map"

# Folders
$pathFolderRoot = $PSScriptRoot;
$pathFolderServer = "$pathFolderRoot\RustServer"
$pathFolderManaged = "$pathFolderServer\RustDedicated_Data\Managed"
$pathFolderAppDataLocal = "$env:LOCALAPPDATA\RustErShell"
$pathFolderSteamCmd = "$pathFolderAppDataLocal\SteamCMD"
$pathFolderCarbon = "$pathFolderServer\carbon"
$pathFolderServerCfg = "$pathFolderServer\server\example\cfg"

# Files
$pathFileSteamCmd = "$pathFolderSteamCmd\steamcmd.exe"
$pathFileTemp = "$pathFolderAppDataLocal\Temp.zip"
$pathFileServerCfg = "$pathFolderServerCfg\server.cfg"
$pathFileRustDedicated = "$pathFolderServer\RustDedicated.exe"
$pathFileOxide = "$pathFolderServer\RustDedicated_Data\Managed\Oxide.Core.dll"
$pathFileConfig = "$pathFolderRoot\RustErShell.cfg"

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
    if (Test-Path ($pathFolderCarbon) -PathType Container)
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

function UninstallCarbon()
{
    if (Test-Path ($pathFolderCarbon) -PathType Container)
    {
        Remove-Item $pathFolderCarbon -Recurse
    }
}

function UninstallOxide()
{
    if (Test-Path ($pathFileOxide))
    {
        Remove-Item $pathFolderManaged -Recurse
        UpdateServer
    }
}

function InstallOxide
{
    Write-Host "[OXIDE] Installing Oxide..."
    DownloadAndExtract -url $urlOxide -extractPath $pathFolderServer
    Write-Host "[OXIDE] Oxide was installed!"
}

function CreateFolders
{
    # Create Server Directory
    if (!(Test-Path -Path $pathFolderServer -PathType Container))
    {
        $null = New-Item -Path $pathFolderServer -ItemType "directory"
    }

    # Create Example server.cfg
    if (!(Test-Path $pathFileServerCfg))
    {
        Write-Host "Creating server.cfg"

        if (!(Test-Path $pathFolderServerCfg))
        {
            $null = New-Item -Path $pathFolderServerCfg -ItemType "directory"
        }
        
        $null = New-Item -Path $pathFileServerCfg -Value "server.worldsize 1500`nserver.maxplayers 5`nfps.limit 256`nbaseboat.generate_paths 0`nantihack.terrain_kill false`nantihack.terrain_protection false`ncensorplayerlist true`nserver.secure false`nserver.levelurl ""$urlTestMap"""
    }
}

function StartServer 
{
    if (Test-Path $pathFileRustDedicated)
    {
        Write-Host "Starting server"
        Start-Process $pathFileRustDedicated -WorkingDirectory $pathFolderServer -ArgumentList "-batchmode -nographics -logFile Log.txt +server.identity ""example"" +oxide.directory ""server/example/oxide/"""
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

function CheckOptions 
{
    param ([string] $option)

    if ($option -eq "0")
    {
        Write-Host "Uninstalling all mods and updating server..."
        UninstallCarbon
        UninstallOxide
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

    if ($option.Contains("9"))
    {
        StartServer
    }
}

function PrintOptions
{
    Write-Host "Select option:"
    Write-Host "1 - Install/Update Server"
    Write-Host "2 - Install Oxide"
    Write-Host "3 - Install Carbon"
    Write-Host "-------------------------"
    Write-Host "9 - Start server after update"
    Write-Host "0 - !!! Uninstall All Mods !!!"
    Write-Host "-------------------------"
    Write-Host "You can select multiple options at once"
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

    $title = "RustErShell v6 ($pathFolderServer)";
    $isCarbon = Test-Path -Path $pathFolderCarbon -PathType Container
    $isOxide = Test-Path -Path $pathFileOxide
    $isServer = Test-Path -Path $pathFileRustDedicated
    $host.ui.RawUI.WindowTitle = $title

    Write-Host $title
    Write-Host " * Server: $isServer"
    Write-Host " * Oxide: $isOxide"
    Write-Host " * Carbon: $isCarbon"
    Write-Host "====================================================================================================================="

    CreateFolders
    
    $option = ""

    if (Test-Path -Path $pathFileConfig)
    {
        $content = Get-Content -Path $pathFileConfig
        $option = $content
        Write-Host "Options selected from config: $option"
        Start-Sleep 3
    }
    else 
    {
        $null = New-Item -Path $pathFileConfig -ItemType File
    }

    if (($null -eq $option) -or ($option -eq ""))
    {
        PrintOptions
        $option = Read-Host "Option"
    }
   
    CheckOptions -option $option.ToString()
    Start-Sleep 3
}

# Start
Load