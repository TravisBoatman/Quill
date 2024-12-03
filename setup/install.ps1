if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Please run this script as an Administrator!"
    exit
}

Install-Module Terminal-Icons -Force
Install-Module PSReadLine -Force

if (Get-Command "oh-my-posh" -ErrorAction SilentlyContinue) {
    Write-Output "Oh-My-Posh is installed. Skipping..."
} else {
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
}

if (Get-Command "gsudo" -ErrorAction SilentlyContinue) {
    Write-Output "gsudo is installed. Skipping..."
} else {
    Set-ExecutionPolicy RemoteSigned -scope Process; [Net.ServicePointManager]::SecurityProtocol = 'Tls12'; Invoke-WebRequest -useb https://raw.githubusercontent.com/gerardog/gsudo/master/installgsudo.ps1 | Invoke-Expression
}

if(-not $env:MY_ENV_VAR) {
    $CurrentScriptPath = $PSScriptRoot
    $ParentDirectory = (Get-Item -Path $CurrentScriptPath).Parent.FullName
    [Environment]::SetEnvironmentVariable("TB_SCRIPTS", "$ParentDirectory", "Machine")
}

Write-Host "Install completed. Close any open consoles then run ps-profile.ps1 to complete setup.`n" -ForegroundColor Yellow