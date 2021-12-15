<#
    .SYNOPSIS
        Resets the Windows Hello for Business container (user context)
    
    .DESCRIPTION
        Resets the Windows Hello for Business container (user context)
    
    .NOTES
        Author: Tobias Sandberg
        Date published: 2021-12-01
        Current version: 1.0
    
    .LINK
        https://www.xenit.se
    
    .EXAMPLE
        Reset-WindowsHello.ps1
        
#>
Start-Transcript -Path $(Join-Path $env:ProgramData\Microsoft\IntuneManagementExtension\Logs "Intune_Reset-WindowsHello_$(Get-Date -Format "yyyy-MM-dd_hh-mm").log")

Write-Host "Resetting Windows Hello with certutil /deletehellocontainer"
certutil /deletehellocontainer

Stop-Transcript
