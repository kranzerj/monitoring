#Backup Check of Last Resort


#Parameter ob Backup erfolgreich war, wird von Veeam geschrieben
#Set successful backup details to this VM attribute -> Last Backup
#https://helpcenter.veeam.com/docs/backup/vsphere/backup_job_advanced_notify_vm.html?ver=120


#OpenAI ChatGPT (GPT-3.5) und COUNT IT Josy ;-)


# VMs to exclude from the check
$excludedVMs = @("VM-Test01","Test-VM")

# vSphere connection details
$vcServer = 'vcenter.kranzer.eu'
$vcUsername = 'Nagios-Backup-Checker@vsphere.local'
$vcPassword = 'hier das Passwort'


# Nagios exit codes
$OK = 0
$WARNING = 1
$CRITICAL = 2
$UNKNOWN = 3


#ka was ihm am Zertifkat nicht passt und die Meldung nervt
Set-PowerCLIConfiguration -ParticipateInCEIP $false -InvalidCertificateAction Ignore -DefaultVIServerMode multiple -Confirm:$false  -ErrorAction Stop | Out-Null



# Connect to vSphere server
Connect-VIServer -Server $vcServer -Username $vcUsername -Password $vcPassword | Out-Null

if ($?) {
    # Get all VMs
    $vms = Get-VM

    if ($vms) {
        $failedVMs = @()

        foreach ($vm in $vms) {
            if ($excludedVMs -contains $vm.Name) {
                continue
            }

            # Get the custom attribute value for Last Backup
            $lastBackupAttribute = Get-Annotation -Entity $vm -CustomAttribute "Backup"

            if ($lastBackupAttribute) {
                $lastBackupValue = $lastBackupAttribute.Value

                # Extract the backup date from the attribute value
                $backupDate = $lastBackupValue -replace "Last backup:\s+\[(\d{2}\.\d{2}.\d{4}\s+\d{2}:\d{2}:\d{2})\].*", '$1'

                if ($backupDate) {
                    $backupDateTime = [DateTime]::ParseExact($backupDate, "dd.MM.yyyy HH:mm:ss", $null)

                    # Check if the backup is older than 60 hours
                    $timeSinceBackup = (Get-Date) - $backupDateTime

                    if ($timeSinceBackup.TotalHours -gt 60) {
                        $failedVMs += $vm.Name
                    }
                } else {
                    $failedVMs += $vm.Name
                }
            } else {
                $failedVMs += $vm.Name
            }
        }

        # Disconnect from vSphere server
        Disconnect-VIServer -Server $vcServer -Force -confirm:$false | Out-Null

        if ($failedVMs) {
            # There are VMs with failed backups
            $failedVMsString = $failedVMs -join ", "
            Write-Host "CRITICAL: Backup failed for VM(s): $failedVMsString"
            exit $CRITICAL
        } else {
            # All VMs have recent backups
            Write-Host "OK: All VMs have recent backups"
            exit $OK
        }
    } else {
        # No VMs found
        Write-Host "CRITICAL: No VMs found on the vSphere server"
        exit $CRITICAL
    }
} else {
    # Unable to connect to vSphere server
    Write-Host "CRITICAL: Unable to connect to the vSphere server"
    exit $CRITICAL
}

#last resort: place the vms under an allied country's command
