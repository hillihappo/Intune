<#
    .SYNOPSIS
        Adding a extensionAttributeValue to a extensionAttributeName for a predefined Application
    
    .DESCRIPTION
        This script will import a CSV file and loop through all users and add the following values that are defined.
 
        PLEASE NOTE!
 
        CSV must be in a specific format:
        Username;extensionAttributeName;extensionAttributeValue
            
    .NOTES
        Author: Tobias Sandberg
        Date published: 2019-06-17
        Current version: 1.0
    
    .LINK
        https://www.xenit.se
        https://tech.xenit.se
        https://tech.xenit.se/extensionattributes-add-values-via-csv-file/
    
    .EXAMPLE
        Add-extensionAttributeValue.ps1
#>
[CmdletBinding()]
Param(
    [string]$csvPath = "PATH TO CSV",
    [string]$LogFilePath = "C:\Windows\Temp\extenstionAttribute.log",
    [string]$applicationName = "XXXX",
    [string]$userName = "",
    [string]$extensionAttributeName = ""
)
Begin{
    function Write-Log
    {
        param
        (
            [Parameter(Mandatory)]
            [string]$Message,  
            [Parameter()]
            [ValidateSet('1','2','3')]
            [int]$Severity = 1 ## Default to a low severity. Otherwise, override
        )
    
        $line = [pscustomobject]@{
            'DateTime' = (Get-Date)
            'Message' = $Message
            'Severity' = $Severity
        }
        if (-not (Test-Path "$LogfilePath"))
        {
            New-Item $LogfilePath -Force
        }
 
        if (((Get-Item -Path $LogfilePath).Length) -gt 3000000) {
 
            ## Create a new log file with a date timestamp for the name
            Remove-Item $LogFilePath -Force
        }
 
        ## Ensure that $LogFilePath is set to a global variable at the top of script
        $line | Export-Csv -Path $LogFilePath -Append -NoTypeInformation
    }
 
    Write-Log -Message "Logging into AzureAD"
    #Connect-AzureAD
 
    # Import CSV
    Write-Log -Message "Importing CSV"
    $csv = Import-Csv -Path $csvPath -Delimiter ';'
}
Process{
    Try
    {
        $applicationID = (Get-AzureADApplication -SearchString $applicationName).AppId
        $applicationID = $applicationID.Replace('-','')
 
        # Script to apply a value on a attribute for an existing user
        foreach($user in $csv)
        {
            $userName = $user.Username
            $extensionAttributeName = $user.extensionAttributeName
            $extensionAttributeValue = $user.extensionAttributeValue
            
            $oldExtensionAttributeValue = (Get-AzureADUserExtension -ObjectId $UserId -ErrorAction SilentlyContinue).get_item("extension_$($applicationID)_$($extensionAttributeName)")
 
            if ($oldExtensionAttributeValue -ne $null)
            {
                Write-Host "ExtensionAttributeValue <$($oldExtensionAttributeValue)> is already set for ExtensionAttributeName <$($extensionAttributeName)> for user $($user.Username)" -ForegroundColor red -BackgroundColor black
                Write-Log -Message "ExtensionAttributeValue <$($oldExtensionAttributeValue)> is alreday set for ExtensionAttributeName <$($extensionAttributeName)> for user $($user.Username)"        
            }
 
            Write-Host "Adding extensionAttribute <$($extensionAttributeValue)> for user $($user.Username)" -ForegroundColor green -BackgroundColor black
            Write-Log -Message "Adding extensionAttribute <$($extensionAttributeValue)> for user $($user.Username)"
 
            $userId = (Get-AzureADUser -ObjectId $userName).ObjectId
            Set-AzureADUserExtension -ObjectId $userId -ExtensionName "extension_$($applicationID)_$($extensionAttributeName)" -ExtensionValue $extensionAttributeValue
        }
    }
    catch
    {
        Write-Error "ERROR: $($Error[0])"
        Write-Log -Message $_.Exception.Message -Severity 3
        Exit $LASTEXITCODE
    }
}
End{
    Write-Log -Message "Script is done"
}