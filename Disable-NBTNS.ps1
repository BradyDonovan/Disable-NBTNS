## Disable NBT-NS on each interface

##################################################
#region Define Functions
##################################################

<#
.SYNOPSIS
Log to $env:windir\Temp.
.DESCRIPTION
Logging function with severity types, so as to play nicest with CMTrace highlighting. Will log to $env:windir\Temp by default.
.PARAMETER Message
The message you want to log.
.PARAMETER MessageType
Severity level of the message you are logging.
.PARAMETER FileName
File name of the log.
.EXAMPLE
Write-Log -Message "Task failed. Reason $_" -MessageType WARNING -FileName TaskLog.log
.NOTES
Because I use this in other scripts, I dynamically generate the file name based off the following:
    $fileName = $script:MyInvocation.MyCommand.Name
    $fileName = $fileName.Replace(".ps1", "")
    $logFile = $fileName + (Get-Date -Format ddMMyyyyhhmmss) + '.log'
    Write-Log -Message "Logging start." -MessageType INFO -FileName $logFile
Contact information for continuing maintenace:
https://github.com/BradyDonovan/
@b_radmn
#>

function Write-Log {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $true)]
        [ValidateSet("INFO", "WARNING", "ERROR")]
        [string]$MessageType,
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )
    process {
        $logPath = "$env:windir\Temp\$FileName"
        IF (Test-Path $logPath) {
            Add-Content -Path $logPath -Value ("$(Get-Date -Format HH:mm:ss) :" + "$MessageType" + ": $Message")
        }
        ELSE {
            New-Item -Path $logPath
            Add-Content -Path $logPath -Value ("$(Get-Date -Format HH:mm:ss) :" + "$MessageType" + ": $Message")
        }
    }
}

##################################################
#endregion
##################################################

##################################################
#region Get Pre-Run Variables
##################################################

#Logging Variables
$fileName = $script:MyInvocation.MyCommand.Name
$fileName = $fileName.Replace(".ps1", "")
$logFile = $fileName + (Get-Date -Format ddMMyyyyhhmmss) + '.log'

#Setting markers for total runtime.
$counterStart = Get-Date

##################################################
#endregion
##################################################

##################################################
#region Begin
##################################################

Write-Log -Message "Starting." -MessageType INFO -FileName $logFile

## Admin privs check
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

IF ($isAdmin) {
    Try {
        $interfaceListing = Get-ChildItem -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces' -Recurse
        IF ($interfaceListing) {
            Write-Log -Message "Found the following interfaces:`r`n$($interfaceListing.Name | Out-String)" -MessageType INFO -FileName $logFile
            foreach ($interface in $interfaceListing) {
                Write-Log -Message "Setting NetbiosOptions to 2 on interface: $($interface.PSChildName)" -MessageType INFO -FileName $logFile
                Set-ItemProperty -Path $interface.PSPath -Name 'NetbiosOptions' -Value 2 -ErrorAction Stop # https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-netbt-interfaces-interface-netbiosoptions#values
            }
        }
    }
    Catch {
        Write-Log -MessageType ERROR -Message "$($_ | Out-String)" -FileName $logFile
        throw "$_"
    }
}
ELSE {
    Write-Log -Message "Process must be running as an Administrator." -MessageType ERROR -FileName $logFile 
}


[int]$runTime = (New-TimeSpan -Start ($counterStart) -End (Get-Date)).TotalMinutes
Write-Log -MessageType INFO -Message "Finished. Total runtime: $runtime minute(s)" -FileName $logFile


##################################################
#endregion
##################################################
