#!/usr/bin/env pwsh

Import-Module posh-git

function isadmin {
    ([Security.Principal.WindowsPrincipal] `
            [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] "Administrator")
}

if (isadmin) {
    $GitPromptSettings.DefaultPromptPrefix.Text = '[Admin] '
    $GitPromptSettings.DefaultPromptPrefix.ForegroundColor = [ConsoleColor]::Red
}

$GitPromptSettings.DefaultPromptPath.ForegroundColor = [ConsoleColor]::Green
$GitPromptSettings.DefaultPromptBeforeSuffix.Text = '`n'

function prompt {
    & $GitPromptScriptBlock
}

function admin {
    param (
    [Parameter(Mandatory=$false)]
    $prog = "pwsh"
    )
    start $prog -Verb RunAs
}

# Visual Studio dev powershell
function Vs-DevEnv {
    Write-Error "Visual Studio installation not found"
}

if (Get-Command Get-CimInstance -errorAction SilentlyContinue)
{
    $VsInfo = Get-CimInstance MSFT_VSInstance -Namespace root/cimv2/vs -WarningAction:SilentlyContinue -errorAction:SilentlyContinue

    if ($VsInfo -ne $null) {
        function Vs-DevEnv {
            & "$($VsInfo.InstallLocation)\\Common7\\Tools\\Launch-VsDevShell.ps1" -Arch amd64 -HostArch amd64 -SkipAutomaticLocation
        }
    }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Set-PSReadLineOption -PredictionSource Plugin

if (Get-Command gpg-connect-agent -errorAction SilentlyContinue) {
    Invoke-Expression "gpg-connect-agent reloadagent /bye" > $null
}

if (Test-Path -Path "$env:VCPKG_ROOT") {
    Import-Module "${env:VCPKG_ROOT}\scripts\posh-vcpkg"
}

if (Test-Path -Path "$env:USERPROFILE/Additional-PwshSettings.ps1") {
    . $env:USERPROFILE/Additional-PwshSettings.ps1
}

# fnm
if (Get-Command fnm -errorAction SilentlyContinue)
{
    fnm -env --use-on-cd --shell power-shell | Out-String | Invoke-Expression
}
